package net.namekdev.theconsole.state.api

import net.namekdev.theconsole.view.api.IConsoleOutput
import net.namekdev.theconsole.view.api.IConsolePromptInput

/**
 * <p>Console Context Manager handles multiple tabs where
 * every tab consists of console context and command line.</p>
 *
 * <p>User Interface code calls creation and destroyment methods
 * so to handle creation and destroyment of console contexts
 *  and command lines listeners.</p>
 */
interface IConsoleContextManager extends IConsoleContextProvider {
	def IConsoleContext createContext(IConsolePromptInput input, IConsoleOutput output)
	def void destroyContext(IConsoleContext context)
	def void setCurrentTabByContext(IConsoleContext context)
}