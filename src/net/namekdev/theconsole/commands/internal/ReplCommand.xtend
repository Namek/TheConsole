package net.namekdev.theconsole.commands.internal

import net.namekdev.theconsole.commands.api.ICommand
import net.namekdev.theconsole.state.api.IConsoleContext
import net.namekdev.theconsole.repl.ReplManager

class ReplCommand implements ICommand {
	static val USAGE = '''
		Usage:
		 * repl list
		 * repl set <repl_name>
		 * repl set <repl_index>
		 * repl reset
	'''

	static val COMMANDS = #["list", "set", "reset"]
	static val SOMEHOW_GREEN = 0x00FF10

	val ReplManager repls

	new(ReplManager replManager) {
		this.repls = replManager
	}

	override run(IConsoleContext executionContext, String[] args) {
		executionContext.jsUtils.assertInfo(args.length > 0, USAGE)

		val replTypeNames = repls.listAvailableReplNames()

		val command = args.get(0)
		var String newReplName = null

		if (command.equals("list")) {
			return replTypeNames.join('\n')
		}
		else if (command.equals("set")) {
			val arg = args.get(1)

			var index = replTypeNames.indexOf(arg)

			if (index < 0) {
				index = Integer.parseUnsignedInt(arg)
				executionContext.jsUtils.assertError(index < replTypeNames.size, "there are only " + replTypeNames.size + " REPLs!")
			}

			newReplName = replTypeNames.get(index)
			repls.setRepl(executionContext, newReplName)

			executionContext.output.addTextEntry("REPL changed to: " + newReplName, SOMEHOW_GREEN)

			return null
		}
		else if (command.equals("reset")) {
			repls.resetRepl(executionContext)
			executionContext.output.addTextEntry("REPL reset to: " + newReplName, SOMEHOW_GREEN)

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

			val replTypeNames = repls.listAvailableReplNames()

			return replTypeNames
				.filter[startsWith(maybeReplName)]
				.map[name | 'set ' + name]
		}

		return COMMANDS.filter[startsWith(testArgument)]
	}
}