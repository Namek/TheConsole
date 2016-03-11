package net.namekdev.theconsole.state

import java.util.ArrayList
import java.util.List
import net.namekdev.theconsole.commands.AliasManager
import net.namekdev.theconsole.commands.CommandLineService
import net.namekdev.theconsole.scripts.ScriptManager
import net.namekdev.theconsole.scripts.internal.AliasScript
import net.namekdev.theconsole.scripts.internal.ExecScript
import net.namekdev.theconsole.state.api.IConsoleContext
import net.namekdev.theconsole.state.api.IConsoleContextManager
import net.namekdev.theconsole.utils.Database
import net.namekdev.theconsole.utils.PathUtils
import net.namekdev.theconsole.utils.api.IDatabase
import net.namekdev.theconsole.view.api.IConsoleOutput
import net.namekdev.theconsole.view.api.IConsolePromptInput
import net.namekdev.theconsole.view.api.IWindowController

class AppStateManager implements IConsoleContextManager {
	ScriptManager scriptManager
	AliasManager aliasManager
	IDatabase database
	val IWindowController windowController

	var lastContextId = 0 as int
	var IConsoleContext defaultContext
	var IConsoleContext currentTabContext
	var InitializationConsoleContext initializationContext
	val List<ContextInfo> contexts = new ArrayList<ContextInfo>()



	new(IWindowController windowController) {
		this.windowController = windowController
		this.initializationContext = new InitializationConsoleContext()

		database = new Database
		try {
			database.load(PathUtils.appSettingsDir + "/settings.db")
		}
		catch (RuntimeException exc) {
			// TODO I wonder if this works
			this.contextOfDefaultTab.proxy.error(exc.message)
		}

		scriptManager = new ScriptManager(database, this)

		val aliasStorage = database.aliasesSection
		aliasManager = new AliasManager(aliasStorage)

		// TODO scripts should request context dynamically!
		scriptManager.put("alias", new AliasScript(aliasManager, aliasStorage))
		scriptManager.put("exec", new ExecScript())
	}



	// management

	override createContext(IConsolePromptInput input, IConsoleOutput output) {
		val newContext = new ConsoleContext(windowController, input, output)
		val commandLineService = new CommandLineService(newContext, scriptManager, aliasManager)

		val info = new ContextInfo(newContext, commandLineService)
		contexts.add(info)

		if (initializationContext != null) {
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
		}

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
		return if (defaultContext != null) defaultContext else initializationContext
	}

	override getContextForCurrentTab() {
		return if (currentTabContext != null) currentTabContext else getContextOfDefaultTab()
	}

	override getContexts() {
		return contexts.map[info|info.context]
	}

}