package net.namekdev.theconsole.view.components

import java.util.ArrayList
import java.util.concurrent.BlockingQueue
import java.util.concurrent.LinkedBlockingQueue
import java.util.function.BiConsumer
import javafx.concurrent.Worker
import javafx.scene.web.WebEngine
import javafx.scene.web.WebView
import net.namekdev.theconsole.view.api.IConsoleOutput
import net.namekdev.theconsole.view.model.ConsoleOutputEntry
import org.w3c.dom.Element
import org.w3c.dom.Text

class ConsoleOutput implements IConsoleOutput {
	WebView web
	WebEngine engine

	val BlockingQueue<Runnable> queue = new LinkedBlockingQueue<Runnable>
	val entries = new ArrayList<ConsoleOutputEntry>(1024)


	new(WebView webView) {
		this.web = webView
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

		web.focusTraversable = false
	}

	def private boolean isWebLoaded() {
		return engine.loadWorker.state == Worker.State.SUCCEEDED
	}

	def boolean isScrolledToBottom() {
		val script = '(window.innerHeight + window.scrollY) >= document.body.offsetHeight'
		return engine.executeScript(script) as Boolean
	}

	def void scrollToBottom() {
		val script = 'window.scrollTo(0, document.body.scrollHeight)'
		engine.executeScript(script)
	}

	def private createEntry() {
		val entry = new ConsoleOutputEntry(this)
		entries.add(entry)
		return entry
	}

	def private createTextEntry(String text, String styleClass, BiConsumer<Element, Text> nodeModifier) {
		val entry = createEntry()

		val Runnable task = [
			val wasAlreadyScrolled = isScrolledToBottom()

			val doc = engine.document
			val body = doc.getElementsByTagName("body").item(0)
			val entryNode = doc.createElement("pre")
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

			if (wasAlreadyScrolled) {
				scrollToBottom()
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

			for (entry : entries) {
				body.removeChild(entry.entryNode)
				entry.dispose()
			}
		]

		if (!isWebLoaded) {
			queue.put(task)
		}
		else {
			task.run()
		}
	}
}
