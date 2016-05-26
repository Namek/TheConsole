package net.namekdev.theconsole.commands.internal

import java.util.List
import net.namekdev.theconsole.commands.api.ICommand
import net.namekdev.theconsole.commands.api.ICommandLineHandler
import net.namekdev.theconsole.commands.repl.CommandLineHandler
import net.namekdev.theconsole.state.api.IConsoleContext
import org.reflections.Reflections

class ReplCommand implements ICommand {
	static val USAGE = '''
		Usage:
		 * repl list
		 * repl set <repl_name>
		 * repl set <repl_index>
	'''

	static val COMMANDS = #["list", "set"]
	static val SOMEHOW_GREEN = 0x00FF10

	val refl = new Reflections(typeof(ICommand).package)
	val List<Class<? extends ICommandLineHandler>> replTypes
	val List<String> replTypeNames


	new() {
		replTypes = refl.getSubTypesOf(ICommandLineHandler).toList
		replTypeNames = replTypes.map[type | type.name]
	}

	override run(IConsoleContext executionContext, String[] args) {
		executionContext.jsUtils.assertInfo(args.length > 0, USAGE)

		val command = args.get(0)

		if (command.equals("list")) {
			return replTypeNames.join('\n')
		}
		else if (command.equals("set")) {
			val arg = args.get(1)

			var index = replTypeNames.indexOf(arg)

			if (index < 0) {
				index = Integer.parseUnsignedInt(arg)
				executionContext.jsUtils.assertError(index < replTypes.size, "there are only " + replTypes.size + " REPLs!")
			}

			val newReplType = replTypes.get(index)

			// is this basic command line handler?
			// it's constructed in a special way (having command manager instance),
			// so we're not going to instantiate a new one
			if (newReplType.equals(CommandLineHandler)) {
				executionContext.commandLineService.resetHandler()
			}

			// any other command line handler should be instantiated dynamically
			else {
				val repl = newReplType.constructors.get(0).newInstance() as ICommandLineHandler
				executionContext.commandLineService.setHandler(repl)
			}

			executionContext.output.addTextEntry("REPL changed to: " + replTypeNames.get(index), SOMEHOW_GREEN)

			return null
		}

		executionContext.output.addErrorEntry("invalid arguments")

		return null
	}

	override completeArgument(IConsoleContext executionContext, String testArgument) {
		if (testArgument.equals('-noargs')) {
			return COMMANDS
		}
		else if (testArgument.startsWith('set')) {
			// complete repl type name
			val maybeReplName = testArgument.substring(3).trim

			return replTypeNames
				.filter[startsWith(maybeReplName)]
				.map[name | 'set ' + name]
		}

		return COMMANDS.filter[startsWith(testArgument)]
	}
}