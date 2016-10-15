package net.namekdev.theconsole.state

import com.google.common.eventbus.Subscribe
import java.awt.Desktop
import java.util.ArrayList
import java.util.List
import javafx.application.Platform
import net.namekdev.theconsole.commands.CommandLineService
import net.namekdev.theconsole.commands.internal.ReplCommand
import net.namekdev.theconsole.events.Events
import net.namekdev.theconsole.events.ResetCommandLineHandlerEvent
import net.namekdev.theconsole.events.ScriptsFolderClickEvent
import net.namekdev.theconsole.modules.ModuleManager
import net.namekdev.theconsole.repl.ReplManager
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
import net.namekdev.theconsole.commands.CommandCollection
import net.namekdev.theconsole.commands.AliasCollection
import net.namekdev.theconsole.commands.internal.AliasCommand
import net.namekdev.theconsole.commands.internal.ExecCommand

class AppStateManager implements IConsoleContextManager {
	JsFilesManager jsFilesManager
	CommandCollection commands
	IDatabase database
	ReplManager replManager
	ModuleManager moduleManager
	val IWindowController windowController

	var IConsoleContext currentTabContext
	val List<ContextInfo> contexts = new ArrayList<ContextInfo>()
	val generalLogs = new AppLogs

	val List<ConsoleContextListener> contextListeners = new ArrayList



	new(IWindowController windowController) {
		this.windowController = windowController

		Events.register(this)

		database = new Database
		try {
			database.load(PathUtils.appSettingsDir + "/settings.db")
		}
		catch (RuntimeException exc) {
			generalLogs.error(exc.message)
		}

		replManager = new ReplManager()


		val aliases = new AliasCollection
		val aliasStorage = database.aliasesSection
		val root = aliasStorage.root

		if (root.size > 0) {
			root.asObject.forEach([node |
				aliases.put(node.name, node.value.asString())
			])
		}

		commands = new CommandCollection(aliases)
		commands.put("alias", new AliasCommand(aliases, aliasStorage))
		commands.put("exec", new ExecCommand())

		moduleManager = new ModuleManager(database, commands, replManager, this)
		jsFilesManager = new JsFilesManager(database, this, commands, moduleManager)
		jsFilesManager.init()

		commands.put("repl", new ReplCommand(replManager))
	}

	@Subscribe()
	def void onOpenScriptFolder(ScriptsFolderClickEvent evt) {
		windowController.visible = false
		Desktop.desktop.open(PathUtils.scriptsDir.toFile)
	}

	@Subscribe()
	def void onResetCommandLineHandlerEvent(ResetCommandLineHandlerEvent evt) {
		replManager.resetRepl(currentTabContext)
		currentTabContext.output.addTextEntry("REPL reset to default CommandLineHandler", ReplCommand.SOMEHOW_GREEN)
	}


	// management

	override createContext(IConsolePromptInput input, IConsoleOutput output) {
		val newContext = new ConsoleContext(windowController, input, output)
		val commandLineService = new CommandLineService(newContext, commands)

		newContext.commandLineService = commandLineService

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