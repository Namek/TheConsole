package net.namekdev.theconsole.commands.api

import javafx.event.EventHandler
import javafx.scene.input.KeyEvent
import net.namekdev.theconsole.state.api.IConsoleContext

interface ICommandLineHandler extends EventHandler<KeyEvent> {
	def void initContext(IConsoleContext context)
}