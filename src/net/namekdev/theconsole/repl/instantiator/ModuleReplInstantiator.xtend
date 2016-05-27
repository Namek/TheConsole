package net.namekdev.theconsole.repl.instantiator

import jdk.nashorn.api.scripting.ScriptObjectMirror
import net.namekdev.theconsole.commands.api.ICommandLineHandler
import net.namekdev.theconsole.commands.api.ICommandLineUtils
import net.namekdev.theconsole.modules.Module
import net.namekdev.theconsole.repl.api.IReplInstantiator
import net.namekdev.theconsole.state.api.IConsoleContext

class ModuleReplInstantiator implements IReplInstantiator {
	val Module module
	val ScriptObjectMirror replObj


	new(Module module, ScriptObjectMirror replObj) {
		this.module = module
		this.replObj = replObj
	}

	override getName() {
		module.name
	}

	override instantiate(IConsoleContext context) {
		new ICommandLineHandler() {
			override initContext(IConsoleContext context, ICommandLineUtils utils) {
				try {
					if (replObj.hasMember("initContext")) {
						replObj.callMember("initContext", context, utils)
					}
				}
				catch (Exception exc) {
					context.output.addErrorEntry(exc.toString)
				}
			}

			override getName() {
				if (replObj.hasMember("getName")) {
					try {
						val name = replObj.callMember("getName") as String

						if (name != null) {
							return name
						}
					}
					catch (Exception exc) { }
				}

				return module.name
			}

			override handleCompletion() {
				if (replObj.hasMember("handleCompletion")) {
					try {
						replObj.callMember("handleCompletion")

					}
					catch (Exception exc) {
						context.output.addErrorEntry(exc.toString)
					}
				}
			}

			override handleExecution(String command) {
				if (replObj.hasMember("handleExecution")) {
					try {
						val ret = replObj.callMember("handleExecution", command)

						if (ret instanceof Boolean) {
							return ret
						}

						return true
					}
					catch (Exception exc) {
						context.output.addErrorEntry(exc.toString)
					}
				}

				return false
			}

			override dispose() {
				if (replObj.hasMember("dispose")) {
					try {
						replObj.callMember("dispose")
					}
					catch (Exception exc) {
						context.output.addErrorEntry(exc.toString)
					}
				}
			}

		}
	}

}