package net.namekdev.theconsole.commands.api

import net.namekdev.theconsole.state.api.IConsoleContext

interface ICommandLineHandler {
	def void initContext(IConsoleContext context, ICommandLineUtils utils)

	/**
	 * Handle argument completion.
	 * <p>Method is called when TAB key is pressed.</p>
	 */
	def void handleCompletion()

	/**
	 * Handles execution of whole command.
	 * <p>Should return {@code false} when command cannot be
	 * executed in any way, e.g. when it's an empty string.</p>
	 */
	def boolean handleExecution(String command)

	/**
	 * Dispose any native streams, connections etc.
	 * <p>Method is called when tab is closed or when
	 * command line handler is changed to other type.</p>
	 */
	def void dispose()
}