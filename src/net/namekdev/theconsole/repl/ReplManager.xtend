package net.namekdev.theconsole.repl

import java.util.List
import java.util.TreeMap
import net.namekdev.theconsole.commands.CommandLineHandler
import net.namekdev.theconsole.commands.api.ICommandLineHandler
import net.namekdev.theconsole.repl.api.IReplInstantiator
import net.namekdev.theconsole.state.api.IConsoleContext
import org.reflections.Reflections

/**
 * REPL stands for Read-Eval-Print Loop.
 *
 * <p>Single {@code ReplManager} instance manages single {@link IConsoleContext}</p>
 */
class ReplManager {
	static val BASIC_REPL_NAME = typeof(CommandLineHandler).name

	val refl = new Reflections(class.package)
	val List<Class<? extends ICommandLineHandler>> builtinReplTypes
	val List<String> builtinReplTypeNames
	val dynamicRepls = new TreeMap<String, IReplInstantiator>



	new() {
		builtinReplTypes = refl.getSubTypesOf(ICommandLineHandler)
			.filter[constructors.length == 1 && constructors.get(0).parameterCount == 0]
			.toList

		builtinReplTypeNames = builtinReplTypes.map[type | type.name]
	}

	def removeDynamicRepl(String name) {
		dynamicRepls.remove(name)
	}

	def removeDynamicRepl(IReplInstantiator repl) {
		removeDynamicRepl(repl.name)
	}

	def putDynamicRepl(IReplInstantiator repl) {
		dynamicRepls.put(repl.name, repl)
	}

	def getDynamicRepl(String name) {
		return dynamicRepls.get(name)
	}

	def List<String> listAvailableReplNames() {
		val names = newArrayList()
		names.addAll(builtinReplTypeNames)
		val a = dynamicRepls.keySet.toList
		names.addAll(a)

		return names
	}

	def ICommandLineHandler getCurrentRepl(IConsoleContext context) {
		return context.commandLineService.handler
	}

	def void setRepl(IConsoleContext context, String replName) {
		val replNames = listAvailableReplNames()

		// is this basic command line handler?
		// it's constructed in a special way (having command manager instance),
		// so we're not going to instantiate a new one
		if (replName.equals(BASIC_REPL_NAME)) {
			resetRepl(context)
		}

		// any other command line handler should be instantiated dynamically
		else if (replNames.contains(replName)) {
			val repl = instantiateDynamicRepl(context, replName)
			context.commandLineService.setHandler(repl)
		}

		else {
			context.output.addErrorEntry("REPL not found: " + replName)
		}
	}

	def void resetRepl(IConsoleContext context) {
		context.commandLineService.resetHandler()
	}

	private def ICommandLineHandler instantiateDynamicRepl(IConsoleContext context, String replName) {
		return dynamicRepls.get(replName).instantiate(context)
	}
}