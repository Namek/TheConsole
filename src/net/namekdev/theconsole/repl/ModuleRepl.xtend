package net.namekdev.theconsole.repl

import net.namekdev.theconsole.commands.api.ICommandLineHandler
import net.namekdev.theconsole.commands.api.ICommandLineUtils
import net.namekdev.theconsole.modules.Module
import net.namekdev.theconsole.state.api.IConsoleContext
import javax.script.ScriptException

class ModuleRepl implements ICommandLineHandler {
	val Module  module
	val IConsoleContext context

	new(Module module, IConsoleContext context) {
		this.module = module
		this.context = context
	}

	override initContext(IConsoleContext context, ICommandLineUtils utils) {
		try {
			context.jsEnv.tempArgs.args = #[context, utils]

			context.jsEnv.evalInScope('''
				var clh = «module.variableName».commandLineHandler;
				clh.context = context
				clh.utils = utils

				var fn = clh.initContext;
				if (fn) {
					fn.apply(clh, TemporaryArgs.args)
				}
			''')
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