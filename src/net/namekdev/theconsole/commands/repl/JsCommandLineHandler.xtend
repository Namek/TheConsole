package net.namekdev.theconsole.commands.repl

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

	override handleCompletion() {
	}

	override handleExecution() {
		val command = utils.getInput()
		context.output.addInputEntry(command)

		val result = context.runUnscopedJs(command) as Object

		if (result instanceof Exception) {
			context.output.addErrorEntry(result.toString())
		}
		else {
			context.output.addTextEntry(result + "")
		}
	}

	override dispose() {
		context = null
		utils = null
	}
}