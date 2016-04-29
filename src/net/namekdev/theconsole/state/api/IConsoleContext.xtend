package net.namekdev.theconsole.state.api

import java.io.PrintWriter
import net.namekdev.theconsole.scripts.ConsoleProxy
import net.namekdev.theconsole.scripts.execution.JavaScriptExecutor
import net.namekdev.theconsole.scripts.execution.JsUtilsProvider
import net.namekdev.theconsole.view.api.IConsoleOutput
import net.namekdev.theconsole.view.api.IConsolePromptInput

interface IConsoleContext {
	def IConsolePromptInput getInput()
	def IConsoleOutput getOutput()
	def ConsoleProxy getProxy()
	def PrintWriter getErrorStream()
	def JsUtilsProvider getJsUtils()
	def JavaScriptExecutor getJsEnv()

	def Object runJs(String code, Object[] args, Object context)
	def Object runUnscopedJs(String code)
}