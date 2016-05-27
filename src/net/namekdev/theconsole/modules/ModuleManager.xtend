package net.namekdev.theconsole.modules

import com.google.common.base.Charsets
import com.google.common.io.Resources
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.Paths
import java.util.Map
import java.util.TreeMap
import jdk.nashorn.api.scripting.ScriptObjectMirror
import net.namekdev.theconsole.commands.CommandManager
import net.namekdev.theconsole.repl.ReplManager
import net.namekdev.theconsole.scripts.execution.JavaScriptEnvironment
import net.namekdev.theconsole.scripts.execution.ScriptAssertError
import net.namekdev.theconsole.state.api.ConsoleContextListener
import net.namekdev.theconsole.state.api.IConsoleContext
import net.namekdev.theconsole.state.api.IConsoleContextProvider
import net.namekdev.theconsole.utils.PathUtils
import net.namekdev.theconsole.utils.api.IDatabase

/**
 * Registers commands.
 *
 * @author Namek
 */
class ModuleManager {
	val static String PACKAGE_JSON = "package.json"
	val static String INDEX_JS = "index.js"

	IConsoleContextProvider consoleContextProvider

	val IDatabase settings
	val Map<String, Module> loadedModules = new TreeMap
	val CommandManager commandManager
	val ReplManager replManager
	val tmpJsEnv = new JavaScriptEnvironment()


	static def isModule(Path dir) {
		val packageJson = Paths.get(dir.toString, PACKAGE_JSON)
		val indexJs = Paths.get(dir.toString, INDEX_JS)

		return Files.exists(packageJson) || Files.exists(indexJs)
	}


	new(IDatabase settings, CommandManager commands, ReplManager repls, IConsoleContextProvider consoleContextProvider) {
		this.settings = settings
		this.commandManager = commands
		this.replManager = repls
		this.consoleContextProvider = consoleContextProvider

		initRequireJs(tmpJsEnv)

		consoleContextProvider.registerContextListener(consoleContextListener)
	}

	def private getLogs() {
		return consoleContextProvider.generalLogs
	}

	def boolean doesFileBelongToModule(Path path) {
		val dir = if (!Files.isDirectory(path)) path.parent else path
		return loadedModules.values.exists[directory.equals(dir)]
	}

	/**
	 * Load or reload a module.
	 */
	def void receiveModulePath(Path moduleFolder) {
		val name = identifyModule(moduleFolder)

		if (loadedModules.containsKey(name)) {
			// reload module
			logs.log("Reloading module: " + name)
			val module = loadedModules.get(name)
			triggerModuleRequire(module)
		}
		else {
			val dir = moduleFolder

			val packageJson = Paths.get(dir.toString, PACKAGE_JSON)
			val indexJs = Paths.get(dir.toString, INDEX_JS)
			var Path entryJs = null

			if (Files.exists(packageJson)) {
				// TODO get 'main' field inside json file
				// TODO validate package.json format, report if this file is in bad format

				entryJs = Paths.get(dir.toString, 'something_main.js')
			}
			else if (Files.exists(indexJs)) {
				entryJs = indexJs
			}
			else {
				logs.error("Couldn't find a module in: " + dir)
			}

			if (entryJs != null) {
				// TODO check if given variable is not already registered for other module.
				// TODO think of algorithm about other variable - maybe some module priorities configurable by user?

				val relativeFilePath = PathUtils.scriptsDir.relativize(entryJs)
				val relativeFilePathStr = PathUtils.normalize(relativeFilePath)
				val pathParts = relativeFilePathStr.split('/')
				val variableName = pathParts.get(pathParts.length-2)

				val moduleStorage = settings.getModulesSection().getSection(name, true)
				val module = new Module(name, entryJs, variableName, moduleStorage)

				logs.log("Loading module: " + name)
				loadedModules.put(name, module)
				triggerModuleRequire(module)
			}
		}
	}

	def receiveModuleDeleted(Path moduleFolder) {
		val name = identifyModule(moduleFolder)

		if (loadedModules.containsKey(name)) {
			// reload module
			val module = loadedModules.get(name)
			triggerModuleUnload(module)
		}
	}

	/**
	 * Gets module name in format: <code>{containerName}/{moduleName}</code>.
	 */
	private def String identifyModule(Path moduleDir) {
		val packageJson = Paths.get(moduleDir.toString, PACKAGE_JSON)

		if (Files.exists(packageJson)) {
			// TODO algorithm: if there is package.json then get
			// author or package name from there, otherwise INDEX_JS
		}
		else {
			val end = moduleDir.nameCount
			return moduleDir.getName(end-2) + '/' + moduleDir.getName(end-1)
		}

		return null
	}

	private def void triggerModuleRequire(Module module) {
		consoleContextProvider.contexts.forEach[context |
			triggerModuleRequire(context.jsEnv, module)
		]
		triggerModuleRequire(tmpJsEnv, module)

		// get current list of commands
		val cmds = tmpJsEnv.eval('''«module.variableName».commands''')
		if (cmds != null) {
			val ret = tmpJsEnv.eval('''
				Java.to(Object.keys(«module.variableName».commands))
			''')
			val commands = (ret as Object[]).map[el | el as String]

			// load/unload commands
			module.refreshCommands(this.commandManager, commands)
		}

		// module may or may have had implement REPL
		val replObj = tmpJsEnv.eval('''«module.variableName».commandLineHandler''') as ScriptObjectMirror
		val replName = module.name
		val hasRepl = module.refreshRepl(replManager, replName, replObj)

		consoleContextProvider.contexts.forEach[context |
			// if this REPL was used in any context then replace it with a new object or reset to default one
			if (replManager.getCurrentRepl(context).name.equals(replName)) {
				if (hasRepl) {
					replManager.setRepl(context, replName)
				}
				else {
					replManager.resetRepl(context)
				}
			}
		]
	}

	/**
	 * Load module be <code>require()</code>-ing given <code>.js</code> file.
	 */
	private def void triggerModuleRequire(JavaScriptEnvironment jsEnv, Module module) {
		// if same module is already loaded then unload it first
		triggerModuleUnload(jsEnv, module)

		// set context of module (`this` variable available in `onload`)
		jsEnv.tempArgs.context = module.context

		// load module and leave it as a global variable «name»
		try {
			val ret = jsEnv.eval('''
				var «module.variableName» = require("«module.relativeEntryFilePath»")

				if («module.variableName».onload)
					«module.variableName».onload.apply(TemporaryArgs.context, null)
			''')
			if (ret instanceof Error || ret instanceof Exception) {
				logs.error(ret.toString)
			}
		}
		catch (ScriptAssertError assertion) {
			logs.error(module.name + " :: module.onload - assertion error: ")

			if (assertion.isError) {
				logs.error(assertion.text)
			}
			else {
				logs.log(assertion.text)
			}
		}
		catch (Exception exc) {
			exc.printStackTrace()
		}
		catch (Error error) {
			error.printStackTrace()
		}
	}

	private def void triggerModuleUnload(Module module) {
		consoleContextProvider.contexts.forEach[context |
			triggerModuleUnload(context.jsEnv, module)
		]
		triggerModuleUnload(tmpJsEnv, module)
	}

	private def void triggerModuleUnload(JavaScriptEnvironment jsEnv, Module module) {
		val moduleObj = jsEnv.getObject(module.variableName)

		if (moduleObj != null) {
			try {
				jsEnv.eval('''
					if («module.variableName».onunload)
						«module.variableName».onunload()

					delete require.cache["«module.relativeEntryFilePath.toString»"]
				''')
			}
			catch (ScriptAssertError assertion) {
				logs.error(module.name + " :: module.onunload - assertion error: ")

				if (assertion.isError) {
					logs.error(assertion.text)
				}
				else {
					logs.log(assertion.text)
				}
			}

			jsEnv.unbindObject(module.variableName)
		}
	}

	private def void initRequireJs(JavaScriptEnvironment jsEnv) {
		val scriptsDir = PathUtils.scriptsDir.toString().replace('\\', '/')
		val requireJsCode = Resources.toString(this.class.getResource("require.js"), Charsets.UTF_8)
			+ '.localDir = "' + scriptsDir + '"'

		jsEnv.eval(requireJsCode)
	}

	val consoleContextListener = new ConsoleContextListener {
		override onNewContextCreated(IConsoleContext context) {
			initRequireJs(context.jsEnv)

			loadedModules.forEach[name, module |
				triggerModuleRequire(context.jsEnv, module)
			]
		}

		override onContextDestroying(IConsoleContext context) {
			loadedModules.forEach[name, module |
				triggerModuleUnload(context.jsEnv, module)
			]
		}
	}
}