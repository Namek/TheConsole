package net.namekdev.theconsole.commands.api

import net.namekdev.theconsole.state.api.IConsoleContext

interface ICommandLineHandler {
	def void initContext(IConsoleContext context, ICommandLineUtils utils)
	def void handleCompletion()
	def void handleExecution()
}