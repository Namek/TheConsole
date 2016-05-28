package net.namekdev.theconsole.repl.instantiator

import net.namekdev.theconsole.modules.Module
import net.namekdev.theconsole.repl.ModuleRepl
import net.namekdev.theconsole.repl.api.IReplInstantiator
import net.namekdev.theconsole.state.api.IConsoleContext

class ModuleReplInstantiator implements IReplInstantiator {
	val Module module


	new(Module module) {
		this.module = module
	}

	override getName() {
		module.name
	}

	override instantiate(IConsoleContext context) {
		return new ModuleRepl(module, context)
	}

}