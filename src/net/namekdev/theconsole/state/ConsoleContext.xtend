package net.namekdev.theconsole.state

import java.io.IOException
import java.io.OutputStream
import java.io.PrintWriter
import java.util.function.BiConsumer
import net.namekdev.theconsole.scripts.ConsoleProxy
import net.namekdev.theconsole.scripts.execution.JavaScriptEnvironment
import net.namekdev.theconsole.scripts.execution.JsUtilsProvider
import net.namekdev.theconsole.state.api.IConsoleContext
import net.namekdev.theconsole.state.api.IConsoleContextManager
import net.namekdev.theconsole.view.api.IConsoleOutput
import net.namekdev.theconsole.view.api.IConsolePromptInput
import net.namekdev.theconsole.view.api.IWindowController

/**
 * Provides everything for a tab.
 * Instantiated by {@link IConsoleContextManager}.
 */
class ConsoleContext implements IConsoleContext {
	val IWindowController windowController
	private var IConsolePromptInput input
	private var IConsoleOutput output
	private var ConsoleProxy proxy
	private var PrintWriter errorStream
	private var JsUtilsProvider jsUtils
	private var JavaScriptEnvironment jsEnv



	// TODO add database here! (or don't because problem down below...)
	// BUT note a new problem: scripts like 'pwd', 'ls', 'cat', 'cd'
	// should have separate configs between tabs.
	// Currently, they're going to be shared. That sux!


	new(IWindowController windowController, IConsolePromptInput input, IConsoleOutput consoleOutput) {
		this.windowController = windowController
		this.input = input
		this.output = consoleOutput
		this.proxy = new ConsoleProxy(consoleOutput, windowController)

		errorStream = new PrintWriter(new OutputStream() {
			StringBuilder sb = new StringBuilder();

			override write(int c) throws IOException {
				if (c == '\n') {
					consoleOutput.addErrorEntry(sb.toString())
					sb = new StringBuilder()
				}
				else {
					sb.append(c as char)
				}
			}
		})

		jsUtils = new JsUtilsProvider(this)
		jsEnv = createJsEnvironment()
	}

	def private createJsEnvironment() {
		val jsEnv = new JavaScriptEnvironment()
		jsEnv.bindObject("Utils", jsUtils)
		jsEnv.bindObject("console", proxy)

		jsEnv.bindObject("assert", new BiConsumer<Boolean, String> {
			override accept(Boolean condition, String error) {
				jsUtils.assertError(condition, error)
			}
		})

		jsEnv.bindObject("assertInfo", new BiConsumer<Boolean, String> {
			override accept(Boolean condition, String text) {
				jsUtils.assertInfo(condition, text)
			}
		})

		return jsEnv
	}

	def switchContext(IConsoleContext context) {
		this.input = context.input
		this.output = context.output
		this.proxy = context.proxy
		this.errorStream = context.errorStream
		this.jsUtils = context.jsUtils
		this.jsEnv = context.jsEnv
	}

	/**
	 * Run JavaScript code in new scope within given context.
	 */
	override runJs(String code, Object[] args, Object context) {
		jsEnv.tempArgs.args = args
		jsEnv.tempArgs.context = context

		return runUnscopedJs("(function(args, Storage) {" + code + "})(Java.from(TemporaryArgs.args), TemporaryArgs.context.Storage)")
	}

	/**
	 * Run JavaScript code without creating any scope and getting any additional context.
	 */
	override runUnscopedJs(String code) {
		return jsEnv.eval(code)
	}

	override getInput() {
		return this.input
	}

	override getOutput() {
		return this.output
	}

	override getProxy() {
		return this.proxy
	}

	override getErrorStream() {
		return this.errorStream
	}

	override getJsUtils() {
		return this.jsUtils
	}

	override getJsEnv() {
		return this.jsEnv
	}
}