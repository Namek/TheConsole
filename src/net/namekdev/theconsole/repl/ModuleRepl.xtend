package net.namekdev.theconsole.repl

import net.namekdev.theconsole.commands.api.ICommandLineHandler
import net.namekdev.theconsole.state.api.IConsoleContext
import net.namekdev.theconsole.commands.api.ICommandLineUtils
import net.namekdev.theconsole.modules.Module

class ModuleRepl implements ICommandLineHandler {
	var IConsoleContext context
	var ICommandLineUtils utils
	val Module module

	new(Module module) {
		this.module = module
	}

	override initContext(IConsoleContext context, ICommandLineUtils utils) {
		this.context = context
		this.utils = utils
	}

	override getName() {
		module.name
	}

	override handleCompletion() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override handleExecution(String command) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	override dispose() {
		context = null
		utils = null
	}

}