package net.namekdev.theconsole.view

import javafx.scene.layout.Pane
import net.namekdev.theconsole.view.base.IConsoleOutput
import javafx.scene.text.Text
import javafx.scene.text.TextFlow
import net.namekdev.theconsole.view.base.IConsoleOutputEntry

package class ConsoleOutput implements IConsoleOutput {
	TextFlow outputTextArea

	new(Pane parent) {
		outputTextArea = new TextFlow
		outputTextArea.styleClass.add("output")
		outputTextArea.prefWidthProperty().bind(parent.widthProperty())
		outputTextArea.prefHeightProperty().bind(parent.heightProperty())

		parent.children.add(outputTextArea)
	}

	def private createEntry(String text, String addStyle) {
		val textEl = new Text(text)
		textEl.styleClass.add("text-entry")

		if (addStyle != null) {
			textEl.styleClass.add(addStyle)
		}

		return new ConsoleOutputEntry(textEl)
	}

	def private createEntry(String text) {
		createEntry(text, null)
	}

	def private addText(Text textEl) {
		outputTextArea.children.add(textEl)
	}

	override addTextEntry(String text, int colorHex) {
		val entry = addTextEntry(text) as ConsoleOutputEntry
		val hexColor = Integer.toHexString(colorHex)
		entry.textEl.style = "-fx-fill: #" + hexColor
		return entry
	}

	override addTextEntry(String text) {
		val entry = createEntry(text + '\n')
		addText(entry.textEl)
		return entry
	}

	override addErrorEntry(String text) {
		val entry = createEntry(text, "error-entry")
		addText(entry.textEl)
		return entry
	}

	override addInputEntry(String text) {
		val entry = createEntry(" > " + text + '\n', "input-entry")
		addText(entry.textEl)
		return entry
	}

	override clear() {
		outputTextArea.children.clear()
	}


	static class ConsoleOutputEntry implements IConsoleOutputEntry {
		public val Text textEl
		int type = 0

		new(Text textEl) {
			this.textEl = textEl
		}

		override setText(String text) {
			textEl.text = text
		}

		override getText() {
			return textEl.text
		}

		override setType(int type) {
			this.type = type
		}

		override getType() {
			return this.type
		}
	}
}
