package net.namekdev.theconsole.state.api

import java.util.List
import java.nio.file.Path

interface IConsoleContextProvider {
	def IConsoleContext getContextOfDefaultTab()
	def IConsoleContext getContextForCurrentTab()
	def List<IConsoleContext> getContexts()

	/**
	 * Load a module into all contexts.
	 */
	def void loadModule(Path entryFile)
}