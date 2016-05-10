package net.namekdev.theconsole.state

import java.util.ArrayList
import java.util.List
import javafx.application.Platform
import net.namekdev.theconsole.commands.CommandLineService
import net.namekdev.theconsole.commands.CommandManager
import net.namekdev.theconsole.modules.ModuleManager
import net.namekdev.theconsole.scripts.JsFilesManager
import net.namekdev.theconsole.state.api.ConsoleContextListener
import net.namekdev.theconsole.state.api.IConsoleContext
import net.namekdev.theconsole.state.api.IConsoleContextManager
import net.namekdev.theconsole.state.logging.AppLogs
import net.namekdev.theconsole.utils.Database
import net.namekdev.theconsole.utils.PathUtils
import net.namekdev.theconsole.utils.api.IDatabase
import net.namekdev.theconsole.view.api.IConsoleOutput
import net.namekdev.theconsole.view.api.IConsolePromptInput
import net.namekdev.theconsole.view.api.IWindowController
import rx.Subscription

class AppStateManager implements IConsoleContextManager {
	JsFilesManager jsFilesManager
	CommandManager commandManager
	IDatabase database
	ModuleManager moduleManager
	val IWindowController windowController

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
		val newContext = new ConsoleContext(windowController, input, output)
		val commandLineService = new CommandLineService(newContext, commandManager)

		val info = new ContextInfo(newContext, commandLineService)
		contexts.add(info)

		Platform.runLater [
			contextListeners.forEach[
				onNewContextCreated(newContext)
			]

			// if this is a first context, then display general logs to it's output
			if (contexts.size == 1) {
				info.subscribeToLogs(generalLogs)
			}
		]

		return newContext
	}

	override destroyContext(IConsoleContext context) {
		contextListeners.forEach[
			onContextDestroying(context)
		]

		val info = contexts.findFirst[info|info.context == context]
		contexts.remove(info)

		info.commandLineService.dispose()

		if (info.unsubscribeLogs()) {
			// find new Context for general logs
			contexts.get(0).subscribeToLogs(generalLogs)
		}
	}

	override setCurrentTabByContext(IConsoleContext context) {
		currentTabContext = context
	}

	private static class ContextInfo {
		public val IConsoleContext context
		public val CommandLineService commandLineService
		public var Subscription logsSubscription

		new(IConsoleContext context, CommandLineService commandLineService) {
			this.context = context
			this.commandLineService = commandLineService
		}

		def void subscribeToLogs(AppLogs generalLogs) {
			logsSubscription = generalLogs.observable.subscribe([log |
				if (log.isError)
					context.output.addErrorEntry(log.text)
				else
					context.output.addTextEntry(log.text)
			])
		}

		def boolean unsubscribeLogs() {
			val isSubscribed = logsSubscription != null
			if (isSubscribed) {
				logsSubscription.unsubscribe()
				logsSubscription = null
			}
			return isSubscribed
		}
	}


	// provider

	override getContextForCurrentTab() {
		currentTabContext
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