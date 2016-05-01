package net.namekdev.theconsole.state.api

interface ConsoleContextListener {
	def void onNewContextCreated(IConsoleContext context)
	def void onContextDestroying(IConsoleContext context)
}