package net.namekdev.theconsole.commands

import net.namekdev.theconsole.commands.api.ICommandLineHandler
import net.namekdev.theconsole.state.api.IConsoleContext

class CommandLineService {
	val IConsoleContext consoleContext

	val ICommandLineHandler basicHandler
	var ICommandLineHandler currentHandler


	new(IConsoleContext consoleContext, CommandManager commandManager) {
		this.consoleContext = consoleContext

		basicHandler = new CommandLineHandler(commandManager)
		resetHandler()
	}

	def void setHandler(ICommandLineHandler handler) {
		handler.initContext(consoleContext)
		consoleContext.input.keyPressHandler = handler
		currentHandler = handler
	}

	def void resetHandler() {
		setHandler(basicHandler)
	}

	def void dispose() {
		consoleContext.input.keyPressHandler = null
	}
}
