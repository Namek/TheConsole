package net.namekdev.theconsole.commands.api

import net.namekdev.theconsole.state.api.IConsoleContext

interface ICommand {
	def Object run(IConsoleContext executionContext, String[] args)
	def String[] completeArgument(IConsoleContext executionContext, String testArgument)
}