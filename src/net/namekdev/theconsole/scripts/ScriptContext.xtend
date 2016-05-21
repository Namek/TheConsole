package net.namekdev.theconsole.scripts

import net.namekdev.theconsole.utils.api.IDatabase.ISectionAccessor

/**
 * Variables available for executed script.
 */
class ScriptContext {
	public val ISectionAccessor Storage
	public var String argToComplete = null

	new(ISectionAccessor storage) {
		this.Storage = storage
	}
}