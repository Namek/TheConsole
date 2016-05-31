package net.namekdev.theconsole.repl

import net.namekdev.theconsole.commands.api.ICommandLineHandler
import net.namekdev.theconsole.commands.api.ICommandLineUtils
import net.namekdev.theconsole.modules.Module
import net.namekdev.theconsole.state.api.IConsoleContext
import javax.script.ScriptException

class ModuleRepl implements ICommandLineHandler {
	val Module  module
	val IConsoleContext context
	var ICommandLineUtils utils


	new(Module module, IConsoleContext context) {
		this.module = module
		this.context = context
	}

	override init(IConsoleContext context, ICommandLineUtils utils) {
		this.utils = utils

		try {
			context.jsEnv.tempArgs.args = #[context, utils]

			val ret = context.jsEnv.evalInScope('''
				var clh = «module.variableName».commandLineHandler;
				clh.context = TemporaryArgs.args[0]
				clh.utils = TemporaryArgs.args[1]

				var fn = clh.init;
				if (fn) {
					fn.apply(clh)
				}
			''')

			if (ret instanceof ScriptException) {
				context.output.addErrorEntry((ret as ScriptException).toString)
			}
		}
		catch (Exception exc) {
			context.output.addErrorEntry(exc.toString)
		}
		finally {
			context.jsEnv.tempArgs.args = null
		}
	}

	override getName() {

		return module.name
	}

	override handleCompletion() {
		try {
			context.jsEnv.tempArgs.args = #[utils.getInput()]

			context.jsEnv.evalInScope('''
				var clh = «module.variableName».commandLineHandler;
				var fn = clh.handleCompletion;
				if (fn) {
					return fn.apply(clh, TemporaryArgs.args)
				}
			''')
		}
		catch (Exception exc) { }
		finally {
			context.jsEnv.tempArgs.args = null
		}
	}

	override handleExecution(String input, ICommandLineUtils utils, IConsoleContext context) {
		try {
			context.jsEnv.tempArgs.args = #[input, utils, context]

			val ret = context.jsEnv.evalInScope('''
				var clh = «module.variableName».commandLineHandler;
				var fn = clh.handleExecution;
				if (fn) {
					fn.apply(clh, TemporaryArgs.args)
				}
			''')

			if (ret instanceof ScriptException) {
				context.output.addErrorEntry((ret as ScriptException).toString)
				return true
			}

			if (ret == null) {
				return true
			}
		}
		catch (Exception exc) { }
		finally {
			context.jsEnv.tempArgs.args = null
		}

		return false
	}

	override dispose() {
		try {
			context.jsEnv.evalInScope('''
				var clh = «module.variableName».commandLineHandler;
				var fn = clh.handleCompletion;
				if (fn) {
					return fn.apply(clh)
				}
			''')
		}
		catch (Exception exc) { }
	}
}