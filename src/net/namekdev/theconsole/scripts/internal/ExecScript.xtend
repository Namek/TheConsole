package net.namekdev.theconsole.scripts.internal

import net.namekdev.theconsole.scripts.api.IScript
import net.namekdev.theconsole.scripts.execution.JsUtilsProvider

class ExecScript implements IScript {
	val JsUtilsProvider utils

	new(JsUtilsProvider utils) {
		this.utils = utils
	}

	override run(String[] args) {
		utils.assertInfo(args.length > 0, "Usage: exec <command_name/app_path + arguments>")

		val filepath = utils.argsToString(args)
		utils.execAsync(filepath)

		return filepath
	}
}
