package net.namekdev.theconsole.view

import javafx.scene.layout.Pane
import net.namekdev.theconsole.view.base.IConsoleOutput
import org.fxmisc.richtext.StyledTextArea
import org.fxmisc.richtext.skin.TextExt
import org.fxmisc.richtext.StyleClassedTextArea

package class ConsoleOutput implements IConsoleOutput {
	StyleClassedTextArea outputTextArea


	new(Pane parent) {
//		outputTextArea = new StyledTextArea<StylerApplier>(new StylerApplier, [ TextExt textNode, StylerApplier styler |
//			textNode.text = textNode.text + "asdasdasdas\r\n"
//			System.out.println(textNode)
//		])
		outputTextArea = new StyleClassedTextArea
		outputTextArea.editable = false
		outputTextArea.wrapText = true
		outputTextArea.prefWidthProperty().bind(parent.widthProperty())
		outputTextArea.prefHeightProperty().bind(parent.heightProperty())

		parent.children.add(outputTextArea)

//        val pane = new VirtualizedScrollPane<>(styledTextArea(initialParagraphStyle, applyParagraphStyle, initialTextStyle, applyStyle));



/*		outputTextArea = new StyledTextArea
		outputTextArea.editable = false
		outputTextArea.content.text = "color test"
		outputTextArea.prefWidthProperty().bind(parent.widthProperty())
		outputTextArea.prefHeightProperty().bind(parent.heightProperty())
		outputTextArea.focusTraversable = false

		parent.children.add(outputTextArea)*/
	}

	override addTextEntry(String text, int colorHex) {
//			outputTextArea.content.text += text
//		outputTextArea.append()
		return null
	}

	override addTextEntry(String text) {
		outputTextArea.appendText(text + '\n')
		return null
	}

	override addErrorEntry(String text) {
		addTextEntry(text, 0xFF0000)
	}

	override addInputEntry(String text) {
		return addTextEntry("< " + text)
	}

	override clear() {
//		outputTextArea.content.text = ""
	}


	static class StylerApplier {

	}

	static class ConsoleOutputEntry {

	}
}
