package net.namekdev.theconsole.scripts

import net.namekdev.theconsole.utils.base.IDatabase.ISectionAccessor

/**
 * Variables available for executed script.
 */
class JsScriptContext {
	public val ISectionAccessor Storage


	new(ISectionAccessor storage) {
		this.Storage = storage
	}
}