package net.namekdev.theconsole.repl

import java.util.List
import net.namekdev.theconsole.commands.api.ICommandLineHandler
import net.namekdev.theconsole.state.api.IConsoleContext
import org.reflections.Reflections
import net.namekdev.theconsole.commands.CommandLineHandler
import java.util.Map
import java.util.SortedMap
import java.util.TreeSet
import net.namekdev.theconsole.repl.api.IReplInstantiator
import java.util.TreeMap

/**
 * REPL stands for Read-Eval-Print Loop.
 *
 * <p>Single {@code ReplManager} instance manages single {@link IConsoleContext}</p>
 */
class ReplManager {
	static val BASIC_REPL_NAME = typeof(CommandLineHandler).name

	val IConsoleContext context
	val refl = new Reflections(class.package)
	val List<Class<? extends ICommandLineHandler>> builtinReplTypes
	val List<String> builtinReplTypeNames
	val dynamicRepls = new TreeMap<String, IReplInstantiator>



	new(IConsoleContext consoleContext) {
		this.context = consoleContext

		builtinReplTypes = refl.getSubTypesOf(ICommandLineHandler).toList
		builtinReplTypeNames = builtinReplTypes.map[type | type.name]
	}

	def removeDynamicRepl(String name) {
		dynamicRepls.remove(name)
	}

	def removeDynamicRepl(IReplInstantiator repl) {
		removeDynamicRepl(repl.name)
	}

	def setDynamicRepl(IReplInstantiator repl) {
		dynamicRepls.put(repl.name, repl)
	}


	def ICommandLineHandler getCurrentRepl() {
		return context.commandLineService.handler
	}

	def List<String> listAvailableReplNames() {
		// TODO add all module-repls

		builtinReplTypeNames
	}

	def List<ICommandLineHandler> listAvailableRepls() {
		// TODO
	}

	def void setRepl(String replName) {
		val replNames = listAvailableReplNames()
		val curRepl = getCurrentRepl()

		if (curRepl.name.equals(replName)) {
			context.output.addErrorEntry("REPL is already set to that type. Not changing.")
			return
		}

		// is this basic command line handler?
		// it's constructed in a special way (having command manager instance),
		// so we're not going to instantiate a new one
		if (replName.equals(BASIC_REPL_NAME)) {
			resetRepl()
		}

		// any other command line handler should be instantiated dynamically
		else if (replNames.contains(replName)) {
			val repl = instantiateDynamicRepl(replName)
			context.commandLineService.setHandler(repl)
		}

		else {
			context.output.addErrorEntry("REPL not found: " + replName)
		}
	}

	def void resetRepl() {
		context.commandLineService.resetHandler()
	}

	private def ICommandLineHandler instantiateDynamicRepl(String replName) {
		return dynamicRepls.get(replName).instantiate(context)
	}
}