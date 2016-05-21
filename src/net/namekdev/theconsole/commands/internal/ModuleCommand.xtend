package net.namekdev.theconsole.commands.internal

import net.namekdev.theconsole.commands.api.ICommand
import net.namekdev.theconsole.modules.Module
import net.namekdev.theconsole.scripts.execution.ScriptAssertError
import net.namekdev.theconsole.state.api.IConsoleContext

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

		try {
			return jsEnv.eval('''
				«module.variableName».commands.«commandName».apply(
					null, [Java.from(«tmpObjName»)]
				)
			''')
		}
		catch (ScriptAssertError assertion) {
			if (assertion.isError) {
				executionContext.output.addErrorEntry(assertion.text)
			}
			else {
				executionContext.output.addTextEntry(assertion.text)
			}

			return null
		}
		finally {
			jsEnv.unbindObject(tmpObjName)
		}
	}

	override completeArgument(IConsoleContext executionContext, String testArgument) {
		// TODO try to call command's _completeArgument() or module's global _completeArgument()
		return #[]
//		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

}