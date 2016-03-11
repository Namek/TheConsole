package net.namekdev.theconsole.scripts.api

import net.namekdev.theconsole.state.api.IConsoleContext

interface IScript {
	def Object run(IConsoleContext executionContext, String[] args)
}