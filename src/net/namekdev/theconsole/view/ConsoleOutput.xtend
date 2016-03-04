package net.namekdev.theconsole.view

import javafx.scene.layout.Pane
import net.namekdev.theconsole.view.base.IConsoleOutput
import org.eclipse.fx.ui.controls.styledtext.StyledTextArea

package class ConsoleOutput implements IConsoleOutput {
	StyledTextArea outputTextArea

	new(Pane parent) {
		outputTextArea = new StyledTextArea
		outputTextArea.editable = false
		outputTextArea.content.text = "color test"
		outputTextArea.prefWidthProperty().bind(parent.widthProperty())
		outputTextArea.prefHeightProperty().bind(parent.heightProperty())
		outputTextArea.focusTraversable = false

		parent.children.add(outputTextArea)
	}

	override addTextEntry(String text, int colorHex) {
//			outputTextArea.content.text += text
		outputTextArea.content.text = text
		return null
	}

	override addTextEntry(String text) {
		addTextEntry(text, 0xFFFFFF)
	}

	override addErrorEntry(String text) {
		addTextEntry(text, 0xFF0000)
	}

	override addInputEntry(String text) {
		return addTextEntry("< " + text)
	}

	override addLogEntry(String text) {
		addTextEntry(text)
	}

	override clear() {
		outputTextArea.content.text = ""
	}
}
