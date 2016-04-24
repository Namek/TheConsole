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
import net.namekdev.theconsole.scripts.api.IScript
import net.namekdev.theconsole.scripts.api.IScriptManager
import net.namekdev.theconsole.state.api.IConsoleContextProvider
import net.namekdev.theconsole.utils.PathUtils
import net.namekdev.theconsole.utils.RecursiveWatcher
import net.namekdev.theconsole.utils.RecursiveWatcher.FileChangeEvent
import net.namekdev.theconsole.utils.api.IDatabase

import static java.nio.file.FileVisitResult.*
import static java.nio.file.StandardWatchEventKinds.ENTRY_CREATE
import static java.nio.file.StandardWatchEventKinds.ENTRY_DELETE
import static java.nio.file.StandardWatchEventKinds.ENTRY_MODIFY
import java.nio.file.FileVisitResult
import java.nio.file.Paths
import java.util.List

class ScriptManager implements IScriptManager {
	final String SCRIPT_FILE_EXTENSION = "js"
	final String PACKAGE_JSON = "package.json"
	final String INDEX_JS = "index.js"

	val Map<String, IScript> scripts = new TreeMap<String, IScript>()
	val scriptNames = new ArrayList<String>()

	IDatabase settingsDatabase
	IDatabase.ISectionAccessor scriptsDatabase
	IConsoleContextProvider consoleContextProvider

	final Path scriptsWatchDir = PathUtils.scriptsDir
	private PathMatcher scriptExtensionMatcher



	new(IDatabase database, IConsoleContextProvider consoleContextProvider) {
		this.settingsDatabase = database
		this.scriptsDatabase = settingsDatabase.getScriptsSection()
		this.consoleContextProvider = consoleContextProvider

		val fs = FileSystems.getDefault()
		scriptExtensionMatcher = fs.getPathMatcher("glob:**/*." + SCRIPT_FILE_EXTENSION)

		if (!Files.isDirectory(scriptsWatchDir)) {
			val path = scriptsWatchDir.toAbsolutePath().toString()
			defaultContextConsole.log("No scripts folder found, creating a new one: " + path)
			new File(path).mkdirs()
		}

		// TODO if the scripts folder doesn't exist, then create it and copy standard scripts from internals

		analyzeScriptsFolder(scriptsWatchDir)

		try {
			val RecursiveWatcher watcher = new RecursiveWatcher(scriptsWatchDir, 500, scriptsFileWatcher)
			watcher.start()
		}
		catch (IOException exc) {
			defaultContextConsole.error(exc.toString())
		}
	}

	def private ConsoleProxy getDefaultContextConsole() {
		return consoleContextProvider.contextOfDefaultTab.proxy
	}

	override get(String name) {
		return scripts.get(name)
	}

	override put(String name, IScript script) {
		scripts.put(name, script)

		if (!scriptNames.exists[n|n.equals(name)]) {
			scriptNames.add(name)
			scriptNames.sort()
		}
	}

	override remove(String name) {
		scripts.remove(name)
		scriptNames.removeIf[n|n.equals(name)]
	}

	override getScriptCount() {
		return scripts.size()
	}

	override getAllScriptNames() {
		return scriptNames
	}

	override createScriptStorage(String name) {
		return scriptsDatabase.getSection(name, true)
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

	def private void analyzeScriptsFolder(Path folder) {
		val console = defaultContextConsole
		val List<Path> modules = new ArrayList
		val List<Path> scripts = new ArrayList

		Files.walkFileTree(folder, new SimpleFileVisitor<Path>() {
			override FileVisitResult preVisitDirectory(Path dir, BasicFileAttributes attrs) {
				val packageJson = Paths.get(dir.toString, PACKAGE_JSON)
				val indexJs = Paths.get(dir.toString, INDEX_JS)

				if (Files.exists(packageJson) || Files.exists(indexJs)) {
					modules.add(dir)

					return SKIP_SUBTREE
				}

				return CONTINUE
			}

			override visitFile(Path file, BasicFileAttributes attr) {
				if (!attr.isRegularFile()) {
					return CONTINUE
				}

				scripts.add(file)

				return CONTINUE
			}

			override FileVisitResult postVisitDirectory(Path dir, IOException exc) {
				return CONTINUE
			}
		})

		// initialize modules first, later normal scripts

		modules.forEach [modulePath |
			tryLoadModule(modulePath)
		]

		scripts.forEach [scriptPath |
			tryReadScriptFile(scriptPath)
		]
	}

	def private void tryReadScriptFile(Path path) {
		if (!scriptExtensionMatcher.matches(path)) {
			return
		}

		val scriptName = pathToScriptName(path)
		val console = defaultContextConsole

		try {
			var code = new String(Files.readAllBytes(path), StandardCharsets.UTF_8)

			// TODO try to pre-compile script for error-check

			var script = get(scriptName)

			if (script == null) {
				console.log("Loading script: " + scriptName)
				script = new Script(this, scriptName, code)
				put(scriptName, script)
			}
			else if (script instanceof Script) {
				console.log("Reloading script: " + scriptName)
				(script as Script).code = code
			}
			else {
				console.error("Cannot overwrite core script: " + scriptName)
			}
		}
		catch (IOException exc) {
			console.error(exc.toString())
		}
	}

	def private void tryLoadModule(Path dir) {
		val console = defaultContextConsole

		if (Files.exists(Paths.get(dir.toString, PACKAGE_JSON))) {

		}
		else if (Files.exists(Paths.get(dir.toString, INDEX_JS))) {

		}
		else {
			console.error("Couldn't find a module in: " + dir)
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
			// TODO check if containing folder is a module
			// (need to go by path up to `scripts` root)

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


}