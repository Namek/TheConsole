package net.namekdev.theconsole.repl.builtin

import net.namekdev.theconsole.commands.api.ICommandLineHandler
import net.namekdev.theconsole.state.api.IConsoleContext
import net.namekdev.theconsole.commands.api.ICommandLineUtils

/**
 * REPL which executes command always as JavaScript code.
 * This REPL doesn't create custom JavaScript context, current tab's context is used.
 */
class JsCommandLineHandler implements ICommandLineHandler {
	var IConsoleContext context
	var ICommandLineUtils utils

	override initContext(IConsoleContext context, ICommandLineUtils utils) {
		this.context = context
		this.utils = utils
	}

	override getName() {
		class.name
	}

	override handleCompletion() {
	}

	override handleExecution(String input, ICommandLineUtils utils, IConsoleContext context) {
		if (input.length == 0) {
			return false
		}

		context.output.addInputEntry(input)

		val result = context.runUnscopedJs(input) as Object

		if (result instanceof Exception) {
			context.output.addErrorEntry(result.toString())
		}
		else {
			context.output.addTextEntry(result + "")
		}

		return true
	}

	override dispose() {
		context = null
		utils = null
	}
}