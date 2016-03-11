package net.namekdev.theconsole.state.api

import java.util.List

interface IConsoleContextProvider {
	def IConsoleContext getContextOfDefaultTab()
	def IConsoleContext getContextForCurrentTab()
	def List<IConsoleContext> getContexts()
}