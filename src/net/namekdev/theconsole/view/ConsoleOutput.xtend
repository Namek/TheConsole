package net.namekdev.theconsole.view

import com.sun.media.jfxmediaimpl.MediaDisposer.Disposable
import java.util.ArrayList
import java.util.concurrent.BlockingQueue
import java.util.concurrent.LinkedBlockingQueue
import java.util.function.BiConsumer
import javafx.concurrent.Worker
import javafx.scene.layout.Pane
import javafx.scene.web.WebEngine
import javafx.scene.web.WebView
import net.namekdev.theconsole.view.base.IConsoleOutput
import net.namekdev.theconsole.view.base.IConsoleOutputEntry
import org.w3c.dom.Element
import org.w3c.dom.Text

package class ConsoleOutput implements IConsoleOutput {
	WebView web = new WebView
	WebEngine engine

	val BlockingQueue<Runnable> queue = new LinkedBlockingQueue<Runnable>
	val entries = new ArrayList<ConsoleOutputEntry>(1024)


	new(Pane parent) {
		engine = web.engine
		engine.userStyleSheetLocation = getClass().getResource("ConsoleOutput_WebView.css").toString
		engine.loadWorker.stateProperty.addListener([ observableValue, state, newState |
			if (newState.equals(Worker.State.SUCCEEDED)) {
				while (!queue.empty) {
					queue.poll.run()
				}
			}
		])
		engine.loadContent("<html><head></head><body></body></html>")

		web.prefWidthProperty().bind(parent.widthProperty())
		web.maxHeightProperty().bind(parent.heightProperty())
		web.focusTraversable = false

		parent.children.add(web)
	}

	def private boolean isWebLoaded() {
		return engine.loadWorker.state == Worker.State.SUCCEEDED
	}

	def private createEntry() {
		val entry = new ConsoleOutputEntry()
		entries.add(entry)
		return entry
	}

	def private createTextEntry(String text, String styleClass, BiConsumer<Element, Text> nodeModifier) {
		val entry = createEntry()

		val Runnable task = [
			val doc = engine.document
			val body = doc.getElementsByTagName("body").item(0)
			val entryNode = doc.createElement("div")
			val textNode = doc.createTextNode(text)

			entryNode.appendChild(textNode)
			body.appendChild(entryNode)

			entry.entryNode = entryNode
			entry.textNode = textNode

			var className = 'entry-text'
			if (styleClass != null) {
				className += ' ' + styleClass
			}
			entryNode.setAttribute("class", className)

			if (nodeModifier != null) {
				nodeModifier.accept(entryNode, textNode)
			}
		]

		if (!isWebLoaded) {
			queue.put(task)
		}
		else {
			task.run()
		}

		return entry
	}

	def private createTextEntry(String text, String styleClass) {
		createTextEntry(text, styleClass, null)
	}

	override addTextEntry(String text, int colorHex) {
		createTextEntry(text, null, [ entryNode, textNode |
			val hexColor = Integer.toHexString(colorHex)
			entryNode.setAttribute("style", "color: #" + hexColor)
		])
	}

	override addTextEntry(String text) {
		createTextEntry(text, null)
	}

	override addErrorEntry(String text) {
		createTextEntry(text, "entry-error")
	}

	override addInputEntry(String text) {
		createTextEntry("> " + text, "entry-input")
	}

	override clear() {
		val Runnable task = [
			val doc = engine.document
			val body = doc.getElementsByTagName("body").item(0)

			// TODO
		]

		if (!isWebLoaded) {
			queue.put(task)
		}
		else {
			task.run()
		}
	}


	static class ConsoleOutputEntry implements IConsoleOutputEntry, Disposable {
		package Element entryNode
		package Text textNode
		boolean isDisposed = false
		int type

		package new() {
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
}
