package net.namekdev.theconsole.commands.internal

import net.namekdev.theconsole.commands.api.ICommand
import net.namekdev.theconsole.scripts.ScriptContext
import net.namekdev.theconsole.state.api.IConsoleContext
import net.namekdev.theconsole.utils.api.IDatabase.ISectionAccessor

class ScriptCommand implements ICommand {
	val String name
	public var String code
	val ScriptContext context


	new(String name, String code, ISectionAccessor scriptStorage) {
		this.name = name
		this.code = code
		context = new ScriptContext(scriptStorage)
	}

	override run(IConsoleContext executionContext, String[] args) {
		return executionContext.runJs(this.code, args, context)
	}

	override completeArgument(String testArgument) {
		// TODO
		throw new UnsupportedOperationException("TODO: think of some completion inside scripts")
	}

}