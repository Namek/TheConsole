package net.namekdev.theconsole.modules

import net.namekdev.theconsole.utils.api.IDatabase.ISectionAccessor

class ModuleContext {
	public val ISectionAccessor Storage

	new(Module module) {
		this.Storage = module.storage
	}
}