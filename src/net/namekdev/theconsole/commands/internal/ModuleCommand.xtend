package net.namekdev.theconsole.commands.internal

import net.namekdev.theconsole.commands.api.ICommand
import net.namekdev.theconsole.modules.Module
import net.namekdev.theconsole.state.api.IConsoleContext
import net.namekdev.theconsole.scripts.execution.ScriptAssertError

class ModuleCommand implements ICommand {
	val Module module
	val String commandName

	new(Module module, String commandName) {
		this.module = module
		this.commandName = commandName
	}

	override run(IConsoleContext executionContext, String[] args) {
		val jsEnv = executionContext.jsEnv

		// temporary register a variable containing arguments
		val tmpObjName = module.variableName + '_' + commandName + '_' + System.nanoTime
		jsEnv.bindObject(tmpObjName, args)

		var Object ret = null
		try {
			return jsEnv.eval('''
				«module.variableName».commands.«commandName».apply(
					null, [Java.from(«tmpObjName»)]
				)
			''')
		}
		catch (ScriptAssertError assertion) {
			if (assertion.isError) {
				executionContext.proxy.error(assertion.text)
			}
			else {
				executionContext.proxy.log(assertion.text)
			}

			return null
		}
		finally {
			jsEnv.unbindObject(tmpObjName)
		}
	}
}