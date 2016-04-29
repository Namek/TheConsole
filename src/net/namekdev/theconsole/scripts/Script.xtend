package net.namekdev.theconsole.scripts

import net.namekdev.theconsole.scripts.api.IScript
import net.namekdev.theconsole.state.api.IConsoleContext
import net.namekdev.theconsole.utils.api.IDatabase.ISectionAccessor

/**
 * This class doesn't have any intelligence since it's totally managed/modified by {@link JsScriptManager}.
 *
 * @author Namek
 * @see JsScriptManager
 */
public class Script implements IScript {
	package String name
	package var String code
	val ScriptContext context


	new(String name, String code, ISectionAccessor scriptStorage) {
		this.name = name
		this.code = code

		context = new ScriptContext(scriptStorage)
	}

	override run(IConsoleContext executionContext, String[] args) {
		return executionContext.runJs(this.code, args, context)
	}
}
