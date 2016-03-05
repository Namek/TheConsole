package net.namekdev.theconsole.scripts

import java.io.File
import java.io.IOException
import java.nio.charset.StandardCharsets
import java.nio.file.FileSystems
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.PathMatcher
import java.nio.file.SimpleFileVisitor
import java.nio.file.attribute.BasicFileAttributes
import java.util.ArrayList
import java.util.Map
import java.util.Queue
import java.util.TreeMap
import java.util.function.BiConsumer
import net.namekdev.theconsole.scripts.api.IScript
import net.namekdev.theconsole.scripts.api.IScriptManager
import net.namekdev.theconsole.scripts.execution.JavaScriptExecutor
import net.namekdev.theconsole.scripts.execution.JsUtilsProvider
import net.namekdev.theconsole.utils.PathUtils
import net.namekdev.theconsole.utils.RecursiveWatcher
import net.namekdev.theconsole.utils.RecursiveWatcher.FileChangeEvent
import net.namekdev.theconsole.utils.base.IDatabase

import static java.nio.file.FileVisitResult.CONTINUE
import static java.nio.file.StandardWatchEventKinds.ENTRY_CREATE
import static java.nio.file.StandardWatchEventKinds.ENTRY_DELETE
import static java.nio.file.StandardWatchEventKinds.ENTRY_MODIFY

class JsScriptManager implements IScriptManager {
	final String SCRIPT_FILE_EXTENSION = "js"

	val Map<String, IScript> scripts = new TreeMap<String, IScript>()
	val scriptNames = new ArrayList<String>()

	JavaScriptExecutor jsEnv
	JsUtilsProvider jsUtils
	IDatabase settingsDatabase
	IDatabase.ISectionAccessor scriptsDatabase
	ConsoleProxy console

	final Path scriptsWatchDir = PathUtils.scriptsDir
	private PathMatcher scriptExtensionMatcher

	val tempArgs = new TemporaryArgs


	new(JsUtilsProvider jsUtils, IDatabase database, ConsoleProxy console) {
		this.jsUtils = jsUtils
		this.settingsDatabase = database
		this.scriptsDatabase = settingsDatabase.getScriptsSection()
		this.console = console
		createJsEnvironment()

		val fs = FileSystems.getDefault()
		scriptExtensionMatcher = fs.getPathMatcher("glob:**/*." + SCRIPT_FILE_EXTENSION)

		if (!Files.isDirectory(scriptsWatchDir)) {
			val path = scriptsWatchDir.toAbsolutePath().toString()
			console.log("No scripts folder found, creating a new one: " + path)
			new File(path).mkdirs()
		}

		// TODO if the scripts folder doesn't exist, then create it and copy standard scripts from internals

		analyzeScriptsFolder(scriptsWatchDir)

		try {
			val RecursiveWatcher watcher = new RecursiveWatcher(scriptsWatchDir, 500, scriptsFileWatcher)
			watcher.start()
		}
		catch (IOException exc) {
			console.error(exc.toString())
		}
	}

	def private void createJsEnvironment() {
		jsEnv = new JavaScriptExecutor()
		jsEnv.bindObject("Utils", jsUtils)
		jsEnv.bindObject("TemporaryArgs", tempArgs)
		jsEnv.bindObject("console", console)

		jsEnv.bindObject("assert", new BiConsumer<Boolean, String> {
			override accept(Boolean condition, String error) {
				jsUtils.assertError(condition, error)
			}
		})

		jsEnv.bindObject("assertInfo", new BiConsumer<Boolean, String> {
			override accept(Boolean condition, String text) {
				jsUtils.assertInfo(condition, text)
			}
		})
	}

	override get(String name) {
		return scripts.get(name)
	}

	def JsScriptManager put(String name, IScript script) {
		scripts.put(name, script)

		if (!scriptNames.exists[n|n.equals(name)]) {
			scriptNames.add(name)
			scriptNames.sort()
		}

		return this
	}

	def void remove(String name) {
		scripts.remove(name)
		scriptNames.removeIf[n|n.equals(name)]
	}

	override getScriptCount() {
		return scripts.size()
	}

	override getAllScriptNames() {
		return scriptNames
	}

	override runUnscopedJs(String code) {
		return jsEnv.eval(code)
	}

	override Object runJs(String code, Object[] args, Object context) {
		tempArgs.args = args
		tempArgs.context = context

		return runUnscopedJs("(function(args, Storage) {" + code + "})(Java.from(TemporaryArgs.args), TemporaryArgs.context.Storage)")
	}

	def IDatabase.ISectionAccessor createScriptStorage(String name) {
		return null
//		return scriptsDatabase.getSection(name, true)
	}

	override findScriptNamesStartingWith(String namePart, ArrayList<String> outNames) {
		if (namePart.length() == 0) {
			return
		}

		for (String scriptName : scriptNames) {
			if (scriptName.indexOf(namePart) == 0) {
				outNames.add(scriptName)
			}
		}
	}

	def private int analyzeScriptsFolder(Path folder) {
		var diff = 0 as int

		try {
			console.log("Analyzing folder structure for ." + SCRIPT_FILE_EXTENSION + " files: " + folder)

			val scriptsCount = scriptNames.size

			Files.walkFileTree(folder, new SimpleFileVisitor<Path>() {
			    override visitFile(Path file, BasicFileAttributes attr) {
					if (!attr.isRegularFile()) {
						return CONTINUE
					}

					tryReadScriptFile(file)

					return CONTINUE
				}
			})

			diff = scriptNames.size - scriptsCount

			if (diff == 0) {
				console.log("No scripts were loaded.")
			}
		}
		catch (IOException exc) {
			console.error(exc.toString())
		}

		return diff
	}

	def private void tryReadScriptFile(Path path) {
		if (!scriptExtensionMatcher.matches(path)) {
			return
		}

		val scriptName = pathToScriptName(path)

		try {
			var code = new String(Files.readAllBytes(path), StandardCharsets.UTF_8)

			// TODO try to pre-compile script for error-check

			var script = get(scriptName)

			if (script == null) {
				console.log("Loading script: " + scriptName)
				script = new JsScript(this, scriptName, code)
				put(scriptName, script)
			}
			else if (script instanceof JsScript) {
				console.log("Reloading script: " + scriptName)
				(script as JsScript).code = code
			}
			else {
				console.error("Cannot overwrite core script: " + scriptName)
			}
		}
		catch (IOException exc) {
			console.error(exc.toString())
		}
	}

	def private void removeScriptByPath(Path path) {
		val scriptName = pathToScriptName(path)
		remove(scriptName)
	}

	def private String pathToScriptName(Path path) {
		var filename = path.getFileName().toString()

		if (filename.toLowerCase().endsWith(SCRIPT_FILE_EXTENSION)) {
			filename = filename.substring(0, filename.length() - SCRIPT_FILE_EXTENSION.length() - 1)
		}

		return filename
	}

	val scriptsFileWatcher = new RecursiveWatcher.WatchListener {
		override onWatchEvents(Queue<FileChangeEvent> events) {
			for (FileChangeEvent evt : events) {
				val fullPath = evt.parentFolderPath.resolve(evt.relativePath)

				if (evt.eventType == ENTRY_CREATE) {
					tryReadScriptFile(fullPath)
				}
				else if (evt.eventType == ENTRY_MODIFY) {
					tryReadScriptFile(fullPath)
				}
				else if (evt.eventType == ENTRY_DELETE) {
					removeScriptByPath(fullPath)
				}
			}
		}
	}


	static class TemporaryArgs {
		public Object[] args
		public Object context
	}
}