package net.namekdev.theconsole.view

import javafx.event.EventHandler
import javafx.fxml.FXML
import javafx.fxml.FXMLLoader
import javafx.scene.control.TextField
import javafx.scene.input.KeyEvent
import javafx.scene.layout.AnchorPane
import javafx.scene.layout.Pane
import org.eclipse.fx.ui.controls.styledtext.StyledTextArea
import javafx.scene.input.KeyCode
import net.namekdev.theconsole.view.base.IConsolePromptInput
import net.namekdev.theconsole.view.base.IConsoleOutput
import javafx.application.Platform

class ConsoleWindow extends AnchorPane {
	@FXML public Pane outputPane
	@FXML public TextField promptInput
	StyledTextArea outputTextArea

	var EventHandler<KeyEvent> keyPressHandler


	public new() {
		val loader = new FXMLLoader(getClass().getResource("ConsoleWindow.fxml"))
		loader.setRoot(this)
		loader.setController(this)
		loader.load()

		getStylesheets().add(getClass().getResource("ConsoleWindow.css").toExternalForm())

		outputTextArea = new StyledTextArea()
		outputTextArea.editable = false
		outputTextArea.content.text = "color test"
		outputTextArea.prefWidthProperty().bind(outputPane.widthProperty())
		outputTextArea.prefHeightProperty().bind(outputPane.heightProperty())
		outputTextArea.focusTraversable = false
		outputPane.children.add(outputTextArea)

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

	public val consoleOutput = new IConsoleOutput {
		override addTextEntry(String text) {

		}

		override addErrorEntry(String text) {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}

		override addInputEntry(String text) {
			return addTextEntry("< " + text)
		}
	}

}