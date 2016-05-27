package net.namekdev.theconsole.state.api

import net.namekdev.theconsole.commands.api.ICommandLineService
import net.namekdev.theconsole.scripts.ConsoleProxy
import net.namekdev.theconsole.scripts.execution.JavaScriptEnvironment
import net.namekdev.theconsole.scripts.execution.JsUtilsProvider
import net.namekdev.theconsole.view.api.IConsoleOutput
import net.namekdev.theconsole.view.api.IConsolePromptInput

interface IConsoleContext {
	def IConsolePromptInput getInput()
	def IConsoleOutput getOutput()
	def ConsoleProxy getProxy()
	def JsUtilsProvider getJsUtils()
	def JavaScriptEnvironment getJsEnv()
	def ICommandLineService getCommandLineService()

	def Object runJs(String code, Object[] args, Object context)
	def Object runUnscopedJs(String code)
}