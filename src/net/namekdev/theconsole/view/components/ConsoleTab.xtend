package net.namekdev.theconsole.view.components

import javafx.application.Platform
import javafx.event.EventHandler
import javafx.fxml.FXML
import javafx.fxml.FXMLLoader
import javafx.scene.control.Tab
import javafx.scene.control.TextField
import javafx.scene.input.KeyEvent
import javafx.scene.layout.AnchorPane
import javafx.scene.web.WebView
import net.namekdev.theconsole.state.api.IConsoleContext
import net.namekdev.theconsole.view.api.IConsolePromptInput

class ConsoleTab extends RenamableTab {
	package var IConsoleContext context
	public val ConsoleOutput consoleOutput

	@FXML private AnchorPane pane
	@FXML private WebView webView
	@FXML private TextField promptInput

	var EventHandler<KeyEvent> keyPressHandler


	new() {
		val tabLoader = new FXMLLoader(getClass().getResource("ConsoleTab.fxml"))
		tabLoader.controller = this
		this.content = tabLoader.load()

		pane.getStylesheets().add(getClass().getResource("ConsoleTab.css").toExternalForm())

		consoleOutput = new ConsoleOutput(webView)

		promptInput.onKeyPressed = new EventHandler<KeyEvent>() {
			override handle(KeyEvent event) {
				if (keyPressHandler != null) {
					keyPressHandler.handle(event)
				}
			}
		}
	}

	def focusInput() {
		promptInput.requestFocus()
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