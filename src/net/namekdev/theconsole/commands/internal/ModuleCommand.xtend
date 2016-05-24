package net.namekdev.theconsole.commands.internal

import jdk.nashorn.api.scripting.ScriptObjectMirror
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

		// temporarily register a variable containing arguments
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
		val jsEnv = executionContext.jsEnv

		// temporarily register a variable containing arguments
		val tmpArgName = module.variableName + '_' + commandName + '_' + System.nanoTime
		jsEnv.bindObject(tmpArgName, testArgument)

		try {
			val ret = jsEnv.eval('''
				(function() {
					var module = «module.variableName»;
					var complFunc = module.commands.«commandName»._completeArgument;
					var arg = «tmpArgName»;

					if (complFunc) {
						return complFunc.apply(null, [arg]);
					}
					else if (module.completeArgument) {
						return module.completeArgument.apply(null, [arg]);
					}

					return null;
				})();
			''')

			if (ret instanceof String[]) {
				return ret
			}
			else if (ret instanceof String) {
				val String[] arr = newArrayOfSize(1)
				arr.set(0, ret as String)
				return arr
			}
			else {
				val jsArr = ret as ScriptObjectMirror

				val String[] arr = newArrayOfSize(jsArr.size)
				for (var i = 0; i < arr.size; i++) {
					arr.set(i, jsArr.getSlot(0).toString)
				}

				return arr
			}
		}
		catch (Exception exc) {	}
		finally {
			jsEnv.unbindObject(tmpArgName)
		}

		return #[]
	}

}