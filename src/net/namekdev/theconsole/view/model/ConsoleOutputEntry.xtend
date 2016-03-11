package net.namekdev.theconsole.view.model

import com.sun.media.jfxmediaimpl.MediaDisposer.Disposable
import net.namekdev.theconsole.view.api.IConsoleOutputEntry
import net.namekdev.theconsole.view.components.ConsoleOutput
import org.w3c.dom.Element
import org.w3c.dom.Text

class ConsoleOutputEntry implements IConsoleOutputEntry, Disposable {
	ConsoleOutput consoleOutput
	public Element entryNode
	public Text textNode
	boolean isDisposed = false
	int type

	new(ConsoleOutput consoleOutput) {
		this.consoleOutput = consoleOutput
	}

	override isValid() {
		return !isDisposed
	}

	override setText(String text) {
		val shouldScroll = consoleOutput.isScrolledToBottom
		textNode.textContent = text

		if (shouldScroll) {
			consoleOutput.scrollToBottom()
		}
	}

	override getText() {
		return textNode.textContent
	}

	override setType(int type) {
		this.type = type
	}

	override getType() {
		return type
	}

	override dispose() {
		isDisposed = true
		entryNode = null
		textNode = null
	}
}
