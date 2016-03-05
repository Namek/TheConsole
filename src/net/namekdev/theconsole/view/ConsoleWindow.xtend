package net.namekdev.theconsole.view

import javafx.application.Platform
import javafx.event.EventHandler
import javafx.fxml.FXML
import javafx.fxml.FXMLLoader
import javafx.scene.control.TextField
import javafx.scene.input.KeyEvent
import javafx.scene.layout.AnchorPane
import javafx.scene.layout.Pane
import net.namekdev.theconsole.view.api.IConsoleOutput
import net.namekdev.theconsole.view.api.IConsolePromptInput

class ConsoleWindow extends AnchorPane {
	@FXML public Pane outputPane
	@FXML public TextField promptInput

	public val IConsoleOutput consoleOutput

	var EventHandler<KeyEvent> keyPressHandler


	public new() {
		val loader = new FXMLLoader(getClass().getResource("ConsoleWindow.fxml"))
		loader.setRoot(this)
		loader.setController(this)
		loader.load()

		getStylesheets().add(getClass().getResource("ConsoleWindow.css").toExternalForm())

		consoleOutput = new ConsoleOutput(outputPane)

		promptInput.onKeyPressed = promptInputKeyPressHandler
	}

	val promptInputKeyPressHandler = new EventHandler<KeyEvent>() {
		override handle(KeyEvent event) {
			if (keyPressHandler != null) {
				keyPressHandler.handle(event)
			}
		}
	}

	public val consolePromptInput = new IConsolePromptInput {
		override getText() {
			return promptInput.text
		}

		override setText(String text) {
			Platform.runLater [
				promptInput.text = text
			]
		}

		override setCursorPosition(int pos) {
			Platform.runLater [
				promptInput.positionCaret(pos)
			]
		}

		override setKeyPressHandler(EventHandler<KeyEvent> handler) {
			keyPressHandler = handler
		}
	}
}