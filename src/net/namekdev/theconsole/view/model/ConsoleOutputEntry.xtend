package net.namekdev.theconsole.view.model

import com.sun.media.jfxmediaimpl.MediaDisposer.Disposable
import net.namekdev.theconsole.view.base.IConsoleOutputEntry
import org.w3c.dom.Element
import org.w3c.dom.Text

class ConsoleOutputEntry implements IConsoleOutputEntry, Disposable {
	public Element entryNode
	public Text textNode
	boolean isDisposed = false
	int type

	new() {
	}

	override isValid() {
		return !isDisposed
	}

	override setText(String text) {
		textNode.textContent = text
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
