package net.namekdev.theconsole.view.api

import javafx.event.EventHandler
import javafx.scene.input.KeyEvent

interface IConsolePromptInput {
	def String getText()
	def void setText(String text)
	def void setCursorPosition(int pos)

	def void setKeyPressHandler(EventHandler<KeyEvent> handler)
}