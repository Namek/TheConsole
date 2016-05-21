package net.namekdev.theconsole.view.components

import javafx.application.Platform
import javafx.event.EventHandler
import javafx.fxml.FXML
import javafx.fxml.FXMLLoader
import javafx.scene.control.TextField
import javafx.scene.input.KeyEvent
import javafx.scene.layout.AnchorPane
import javafx.scene.web.WebView
import net.namekdev.theconsole.state.api.IConsoleContext
import net.namekdev.theconsole.view.api.IConsolePromptInput
import net.namekdev.theconsole.view.utils.TextFieldCaretWatcher
import net.namekdev.theconsole.view.utils.WebViewSelectionToClipboard

class ConsoleTab extends RenamableTab {
	package var IConsoleContext context
	public val ConsoleOutput consoleOutput

	@FXML private AnchorPane pane
	@FXML private WebView webView
	@FXML private TextField promptInput

	var EventHandler<KeyEvent> keyPressHandler
	val TextFieldCaretWatcher promptInputCaretWatcher
	val WebViewSelectionToClipboard webViewSelectionWatcher


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

		promptInputCaretWatcher = new TextFieldCaretWatcher(promptInput)
		webViewSelectionWatcher = new WebViewSelectionToClipboard(webView, [
			focusInput()
		])
	}

	def void dispose() {
		promptInputCaretWatcher.dispose()
		webViewSelectionWatcher.dispose()
	}

	def focusInput() {
		promptInput.requestFocus()
	}


	public val consolePromptInput = new IConsolePromptInput {
		volatile var boolean hasTextToSet = false
		volatile var boolean hasCursorPosToSet = false
		var String tmpTextToSet
		var int tmpCursorPosToSet

		override getText() {
			return if (hasTextToSet) tmpTextToSet else promptInput.text
		}

		override setText(String text) {
			hasTextToSet = true
			tmpTextToSet = text

			Platform.runLater [
				promptInput.text = text
				hasTextToSet = false
				tmpTextToSet = null
			]
		}

		override getCursorPosition() {
			return if (hasCursorPosToSet) tmpCursorPosToSet else promptInput.caretPosition
		}

		override setCursorPosition(int pos) {
			hasCursorPosToSet = true
			tmpCursorPosToSet = pos

			Platform.runLater [
				promptInput.positionCaret(pos)
				hasCursorPosToSet = false
				tmpCursorPosToSet = -1
			]
		}

		override setKeyPressHandler(EventHandler<KeyEvent> handler) {
			keyPressHandler = handler
		}
	}
}