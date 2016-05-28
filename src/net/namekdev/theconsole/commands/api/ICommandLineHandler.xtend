package net.namekdev.theconsole.commands.api

import net.namekdev.theconsole.state.api.IConsoleContext

interface ICommandLineHandler {
	def void initContext(IConsoleContext context, ICommandLineUtils utils)

	/**
	 * Returns name of command line handler.
	 * <p>In js modules: if it's not implemented,
	 * then module's name is returned automatically.</p>
	 */
	def String getName()

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
	def boolean handleExecution(String input, ICommandLineUtils utils, IConsoleContext context)

	/**
	 * Dispose any native streams, connections etc.
	 * <p>Method is called when tab is closed or when
	 * command line handler is changed to other type.</p>
	 */
	def void dispose()
}