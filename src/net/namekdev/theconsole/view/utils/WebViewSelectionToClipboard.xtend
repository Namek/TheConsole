package net.namekdev.theconsole.view.utils

import javafx.application.Platform
import javafx.event.EventHandler
import javafx.scene.input.Clipboard
import javafx.scene.input.ClipboardContent
import javafx.scene.input.MouseEvent
import javafx.scene.web.WebView

/**
 * This util listens for mouse events to copy selected text when mouse up event comes in.
 */
class WebViewSelectionToClipboard {
	val WebView web
	var Runnable onTextCopiedHandler
	var String lastCopiedText = null

	new(WebView web, Runnable onTextCopiedHandler) {
		this.web = web
		web.onMouseReleased = onMouseReleasedHandler
		this.onTextCopiedHandler = onTextCopiedHandler
	}

	def void dispose() {
		web.removeEventHandler(MouseEvent.MOUSE_RELEASED, onMouseReleasedHandler)
		this.onTextCopiedHandler = null
	}

	private def void copySelectedTextToClipboard() {
		Platform.runLater [
			val script = 'window.getSelection().toString()'
			val text = web.engine.executeScript(script) as String
			val content = new ClipboardContent()
			val textToCopy = text.trim

			if (textToCopy != null && !textToCopy.equals("") && !textToCopy.equals(lastCopiedText)) {
				content.putString(textToCopy)
				Clipboard.systemClipboard.setContent(content)
				lastCopiedText = textToCopy
				onTextCopiedHandler.run()
			}
		]
	}

	private val EventHandler<MouseEvent> onMouseReleasedHandler = [
		copySelectedTextToClipboard()
	]
}