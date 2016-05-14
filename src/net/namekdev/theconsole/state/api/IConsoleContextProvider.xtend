package net.namekdev.theconsole.state.api

import java.util.List
import net.namekdev.theconsole.state.logging.AppLogs

interface IConsoleContextProvider {
	def IConsoleContext getContextOfDefaultTab()
	def IConsoleContext getContextForCurrentTab()
	def List<IConsoleContext> getContexts()
	def AppLogs getGeneralLogs()

	def void registerContextListener(ConsoleContextListener listener)
}