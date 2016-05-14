package net.namekdev.theconsole.state

import java.util.ArrayList
import java.util.List
import java.util.concurrent.BlockingQueue
import java.util.concurrent.LinkedBlockingQueue
import java.util.function.Consumer
import javafx.application.Platform
import net.namekdev.theconsole.commands.CommandLineService
import net.namekdev.theconsole.commands.CommandManager
import net.namekdev.theconsole.modules.ModuleManager
import net.namekdev.theconsole.scripts.JsFilesManager
import net.namekdev.theconsole.state.api.ConsoleContextListener
import net.namekdev.theconsole.state.api.IConsoleContext
import net.namekdev.theconsole.state.api.IConsoleContextManager
import net.namekdev.theconsole.utils.Database
import net.namekdev.theconsole.utils.PathUtils
import net.namekdev.theconsole.utils.api.IDatabase
import net.namekdev.theconsole.view.api.IConsoleOutput
import net.namekdev.theconsole.view.api.IConsolePromptInput
import net.namekdev.theconsole.view.api.IWindowController
import rx.Observable
import net.namekdev.theconsole.state.logging.AppLogs

class AppStateManager implements IConsoleContextManager {
	JsFilesManager jsFilesManager
	CommandManager commandManager
	IDatabase database
	ModuleManager moduleManager
	val IWindowController windowController

	var lastContextId = 0 as int
	var IConsoleContext defaultContext
	var IConsoleContext currentTabContext
	val List<ContextInfo> contexts = new ArrayList<ContextInfo>()
	val generalLogs = new AppLogs

	val List<ConsoleContextListener> contextListeners = new ArrayList



	new(IWindowController windowController) {
		this.windowController = windowController

		database = new Database
		try {
			database.load(PathUtils.appSettingsDir + "/settings.db")
		}
		catch (RuntimeException exc) {
			generalLogs.error(exc.message)
		}

		commandManager = new CommandManager(database)
		moduleManager = new ModuleManager(database, commandManager, this)
		jsFilesManager = new JsFilesManager(database, this, commandManager, moduleManager)




		jsFilesManager.init()


	}



	// management

	override createContext(IConsolePromptInput input, IConsoleOutput output) {
		val newContext = new ConsoleContext(windowController, input, output, getGeneralLogs)
		val commandLineService = new CommandLineService(newContext, commandManager)

		val info = new ContextInfo(newContext, commandLineService)
		contexts.add(info)

		Platform.runLater [
			contextListeners.forEach[
				onNewContextCreated(newContext)
			]
		]

		/*if (initializationContext != null) {
			val entries = initializationContext.entries
			initializationContext = null
			defaultContext = newContext

			for (entry : entries) {
				if (entry.isError) {
					newContext.output.addErrorEntry(entry.text)
				}
				else {
					newContext.output.addTextEntry(entry.text)
				}
			}
		}*/

		return newContext
	}

	override destroyContext(IConsoleContext context) {
		val info = contexts.findFirst[info|info.context == context]

		info.commandLineService.dispose()
		(info.context as ConsoleContext).switchContext(contextOfDefaultTab)
	}

	override setCurrentTabByContext(IConsoleContext context) {
		currentTabContext = context
	}

	private static class ContextInfo {
		public val IConsoleContext context
		public val CommandLineService commandLineService

		new(IConsoleContext context, CommandLineService commandLineService) {
			this.context = context
			this.commandLineService = commandLineService
		}
	}


	// provider

	override getContextOfDefaultTab() {
		defaultContext
	}

	override getContextForCurrentTab() {
		return if (currentTabContext != null) currentTabContext else getContextOfDefaultTab()
	}

	override getContexts() {
		return contexts.map[info|info.context]
	}

	override getGeneralLogs() {
		generalLogs
	}

	override registerContextListener(ConsoleContextListener listener) {
		contextListeners.add(listener)
	}
}