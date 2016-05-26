package net.namekdev.theconsole.repl.instatiator

import net.namekdev.theconsole.repl.api.IReplInstantiator
import net.namekdev.theconsole.modules.Module
import net.namekdev.theconsole.state.api.IConsoleContext
import net.namekdev.theconsole.repl.ModuleRepl

class ModuleReplInstantiator implements IReplInstantiator {
	Module module

	new(Module module) {
		this.module = module
	}

	override getName() {
		module.name
	}

	override instantiate(IConsoleContext context) {
		new ModuleRepl(module)
	}

}