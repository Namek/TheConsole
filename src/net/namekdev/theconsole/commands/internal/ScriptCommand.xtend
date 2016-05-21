package net.namekdev.theconsole.commands.internal

import jdk.nashorn.api.scripting.ScriptObjectMirror
import net.namekdev.theconsole.commands.api.ICommand
import net.namekdev.theconsole.scripts.ScriptContext
import net.namekdev.theconsole.state.api.IConsoleContext
import net.namekdev.theconsole.utils.api.IDatabase.ISectionAccessor

class ScriptCommand implements ICommand {
	val String name
	val ScriptContext context

	var String[] features
	var boolean supportsArgumentCompletion
	var String code



	new(String name, ISectionAccessor scriptStorage) {
		this.name = name
		context = new ScriptContext(scriptStorage)
	}

	override run(IConsoleContext executionContext, String[] args) {
		return executionContext.runJs(this.code, args, context)
	}

	override completeArgument(IConsoleContext executionContext, String testArgument) {
		if (!supportsArgumentCompletion)
			return null

		val code = code

		try {
			context.argToComplete = testArgument
			val ret = executionContext.runJs(code, null, context)

			if (ret instanceof String) {
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
		catch (Exception exc) { }
		finally {
			context.argToComplete = null
		}

		return null
	}

	def void setup(String code, String[] features) {
		this.code = code
		this.features = features
		supportsArgumentCompletion = features.contains('argumentCompletion')
	}
}