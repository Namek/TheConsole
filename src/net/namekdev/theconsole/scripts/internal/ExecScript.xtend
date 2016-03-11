package net.namekdev.theconsole.scripts.internal

import net.namekdev.theconsole.scripts.api.IScript
import net.namekdev.theconsole.state.api.IConsoleContext

class ExecScript implements IScript {
	override Object run(IConsoleContext executionContext, String[] args) {
		val utils = executionContext.jsUtils
		utils.assertInfo(args.length > 0, "Usage: exec <command_name/app_path + arguments>")

		val filepath = utils.argsToString(args)
		utils.execAsync(filepath)

		return filepath
	}
}
