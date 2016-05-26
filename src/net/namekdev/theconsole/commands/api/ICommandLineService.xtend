package net.namekdev.theconsole.commands.api

interface ICommandLineService {
	/**
	 * Sets custom command line handler.
	 */
	def void setHandler(ICommandLineHandler handler)

	/**
	 * Reset to basic command line handler that operates on CommandManager.
	 */
	def void resetHandler()

	/**
	 * Gets current handler.
	 */
	def ICommandLineHandler getHandler()
}