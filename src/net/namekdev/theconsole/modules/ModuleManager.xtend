package net.namekdev.theconsole.modules

import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.Paths
import java.util.Map
import java.util.TreeMap
import net.namekdev.theconsole.commands.CommandManager
import net.namekdev.theconsole.scripts.ConsoleProxy
import net.namekdev.theconsole.scripts.execution.JavaScriptExecutor
import net.namekdev.theconsole.state.api.ConsoleContextListener
import net.namekdev.theconsole.state.api.IConsoleContext
import net.namekdev.theconsole.state.api.IConsoleContextProvider
import net.namekdev.theconsole.utils.PathUtils

/**
 * Registers commands.
 *
 * @author Namek
 */
class ModuleManager {
	val static String PACKAGE_JSON = "package.json"
	val static String INDEX_JS = "index.js"

	IConsoleContextProvider consoleContextProvider

	val Map<String, Module> loadedModules = new TreeMap
	val CommandManager commands


	static def isModule(Path dir) {
		val packageJson = Paths.get(dir.toString, PACKAGE_JSON)
		val indexJs = Paths.get(dir.toString, INDEX_JS)

		return Files.exists(packageJson) || Files.exists(indexJs)
	}


	new(CommandManager commands, IConsoleContextProvider consoleContextProvider) {
		this.commands = commands
		this.consoleContextProvider = consoleContextProvider

		consoleContextProvider.registerContextListener(consoleContextListener)
	}

	def private ConsoleProxy getDefaultContextConsole() {
		return consoleContextProvider.contextOfDefaultTab.proxy
	}

	def boolean doesFileBelongToModule(Path path) {
		val dir = if (!Files.isDirectory(path)) path.parent else path
		return loadedModules.values.exists[directory.equals(dir)]
	}

	/**
	 * Load or reload a module.
	 */
	def void receiveModulePath(Path moduleFolder) {
		// TODO register commands
		val name = identifyModule(moduleFolder)

		if (loadedModules.containsKey(name)) {
			// reload module
			defaultContextConsole.log("Reloading module: " + name)
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
				defaultContextConsole.error("Couldn't find a module in: " + dir)
			}

			if (entryJs != null) {
				val module = new Module(entryJs)

				defaultContextConsole.log("Loading module: " + name)
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
			triggerModuleRequire(context, module)
		]
	}

	private def void triggerModuleRequire(IConsoleContext context, Module module) {
		triggerModuleRequire(context.jsEnv, module.entryFile)
	}

	/**
	 * Load module be <code>require()</code>-ing given <code>.js</code> file.
	 */
	private def void triggerModuleRequire(JavaScriptExecutor jsEnv, Path entryFile) {
		// TODO Refactor: unify identification
		val path = PathUtils.normalize(PathUtils.scriptsDir.relativize(entryFile))
		val pathParts = path.split('/')
		val name = pathParts.get(pathParts.length-2)

		// if same module is already loaded then unload it first
		triggerModuleUnload(jsEnv, entryFile)

		// load module and leave it as a global variable «name»
		jsEnv.eval('''
			var «name» = require("«path»")

			if («name».onload)
				«name».onload()
		''')
	}

	private def void triggerModuleUnload(Module module) {
		consoleContextProvider.contexts.forEach[context |
			triggerModuleUnload(context.jsEnv, module.entryFile)
		]
	}

	private def void triggerModuleUnload(JavaScriptExecutor jsEnv, Path entryFile) {
		// TODO Refactor: unify identification
		val path = PathUtils.normalize(PathUtils.scriptsDir.relativize(entryFile))
		val pathParts = path.split('/')
		val name = pathParts.get(pathParts.length-2)

		val module = jsEnv.getObject(name)
		if (module != null) {
			jsEnv.eval('''
				if («name».onunload)
					«name».onunload()
			''')
		}
	}


	val consoleContextListener = new ConsoleContextListener {
		override onNewContextCreated(IConsoleContext context) {
			loadedModules.forEach[name, module |
				triggerModuleRequire(context, module)
			]
		}

		override onContextDestroying(IConsoleContext context) {
			loadedModules.forEach[name, module |
				context.jsEnv.triggerModuleUnload(module.entryFile)
			]
		}
	}
}