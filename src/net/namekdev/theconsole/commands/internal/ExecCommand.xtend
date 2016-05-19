package net.namekdev.theconsole.commands.internal

import net.namekdev.theconsole.commands.api.ICommand
import net.namekdev.theconsole.state.api.IConsoleContext
import net.namekdev.theconsole.utils.PathUtils

class ExecCommand implements ICommand {
	override Object run(IConsoleContext executionContext, String[] args) {
		val utils = executionContext.jsUtils
		utils.assertInfo(args.length > 0, "Usage: exec <command_name/app_path + arguments>")

		val filepath = utils.argsToString(args)
		utils.execAsync(filepath)

		return filepath
	}

	override completeArgument(String testArgument) {
		return PathUtils.tryCompletePath(testArgument)
	}
}
