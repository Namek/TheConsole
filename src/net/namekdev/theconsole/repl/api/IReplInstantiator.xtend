package net.namekdev.theconsole.repl.api

import net.namekdev.theconsole.commands.api.ICommandLineHandler
import net.namekdev.theconsole.state.api.IConsoleContext

interface IReplInstantiator {
	def String getName()
	def ICommandLineHandler instantiate(IConsoleContext context)
}