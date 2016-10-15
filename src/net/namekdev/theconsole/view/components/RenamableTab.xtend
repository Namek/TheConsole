package net.namekdev.theconsole.view.components

import javafx.scene.control.Tab
import javafx.scene.control.Label
import javafx.scene.control.TextField
import javafx.event.EventHandler
import javafx.scene.input.MouseEvent
import javafx.event.ActionEvent
import javafx.beans.value.ChangeListener
import javafx.scene.input.KeyEvent
import javafx.scene.input.KeyCode

class RenamableTab extends Tab {
	private Label label
	private TextField textField

	new() {
		label = new Label("Default")
		textField = new TextField()

		setGraphic(label)
		label.setOnMouseClicked(onMouseClicked_label)
		textField.onAction = onAction_textField
		textField.onKeyPressed = onKeyPressed_textField
		textField.focusedProperty().addListener(onFocusPropertyChanged_textField)
	}

	def setHeaderText(String text) {
		label.text = text
	}

	def getHeaderText() {
		return label.text
	}


	private val EventHandler<MouseEvent> onMouseClicked_label = [ evt |
		if (evt.getClickCount() == 2) {
			textField.setText(label.text)
			setGraphic(textField)
			textField.selectAll()
			textField.requestFocus()
		}
	]

	private val EventHandler<ActionEvent> onAction_textField = [ evt |
		label.setText(textField.text)
		setGraphic(label)
	]

	private val EventHandler<KeyEvent> onKeyPressed_textField = [ evt |
		if (evt.code == KeyCode.ESCAPE) {
			setGraphic(label)
			textField.text = label.text
			evt.consume()
		}
	]

	private val ChangeListener<Boolean> onFocusPropertyChanged_textField = [ ov, oldVal, newVal |
		if (!newVal) {
			label.setText(textField.text)
			setGraphic(label)
		}
	]
}
