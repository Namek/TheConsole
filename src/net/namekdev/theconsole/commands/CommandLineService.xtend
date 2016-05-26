package net.namekdev.theconsole.commands

import javafx.event.EventHandler
import javafx.scene.input.KeyCode
import javafx.scene.input.KeyEvent
import net.namekdev.theconsole.commands.api.ICommandLineHandler
import net.namekdev.theconsole.commands.api.ICommandLineUtils
import net.namekdev.theconsole.state.api.IConsoleContext
import net.namekdev.theconsole.view.api.IConsoleOutputEntry

class CommandLineService implements ICommandLineUtils, EventHandler<KeyEvent> {
	val IConsoleContext consoleContext

	val ICommandLineHandler basicHandler
	var ICommandLineHandler currentHandler

	var IConsoleOutputEntry lastAddedEntry
	val CommandHistory history = new CommandHistory
	var String temporaryCommandName

	val SPACE_CHAR = 32 as char


	new(IConsoleContext consoleContext, CommandManager commandManager) {
		this.consoleContext = consoleContext
		consoleContext.input.keyPressHandler = this

		basicHandler = new CommandLineHandler(commandManager)
		resetHandler()
	}

	def void setHandler(ICommandLineHandler handler) {
		handler.initContext(consoleContext, this)

		if (handler != currentHandler && handler != basicHandler) {
			currentHandler.dispose()
		}

		currentHandler = handler
	}

	def void resetHandler() {
		setHandler(basicHandler)
	}

	def void dispose() {
		consoleContext.input.keyPressHandler = null
		currentHandler.dispose()

		if (basicHandler != currentHandler) {
			basicHandler.dispose()
		}
	}

	override setInputEntry(String text) {
		if (text == null) {
			lastAddedEntry = null
			return
		}

		if (lastAddedEntry != null) {
			if (!lastAddedEntry.valid) {
				lastAddedEntry = null
			}
		}

		// don't add the same output second time
		if (lastAddedEntry == null || lastAddedEntry.type != IConsoleOutputEntry.INPUT) {
			lastAddedEntry = consoleContext.output.addTextEntry(text)
			lastAddedEntry.type = IConsoleOutputEntry.INPUT
		}
		else if (lastAddedEntry != null) {
			// modify existing text entry
			lastAddedEntry.setText(text)
		}
	}

	override setInput(String text) {
		setInput(text, -1)
	}

	override setInput(String text, int caretPos) {
		consoleContext.input.setText(text)
		consoleContext.input.setCursorPosition(if (caretPos >= 0) caretPos else text.length())
	}

	override getInput() {
		return consoleContext.input.getText()
	}

	override getInputCursorPosition() {
		return consoleContext.input.cursorPosition
	}

	override countSpacesInInput() {
		var count = 0 as int
		val str = getInput()

		for (var i = 0, val n = str.length(); i < n; i++) {
			if (str.charAt(i) == SPACE_CHAR) {
				count++
			}
		}

		return count
	}


	override handle(KeyEvent evt) {
		switch (evt.code) {
			case KeyCode.TAB: {
				currentHandler.handleCompletion()
				evt.consume()
			}

			case KeyCode.ENTER: {
				val fullCommand = getInput()

				if (fullCommand.length() > 0) {
					consoleContext.output.addInputEntry(fullCommand)
					currentHandler.handleExecution()
					setInput("")
					history.save(fullCommand)
					lastAddedEntry = null
					temporaryCommandName = null
					history.resetPointer()
				}
			}

			case KeyCode.ESCAPE: {
				setInput("")
				lastAddedEntry = null

				if (temporaryCommandName == null) {
					history.resetPointer()
				}
				else {
					temporaryCommandName = null
				}
			}

			case KeyCode.BACK_SPACE,
			case KeyCode.DELETE: //DELETE
			{
				if (consoleContext.input.text.length == 0) {
					// forget old entry
					lastAddedEntry = null
				}
			}

			case KeyCode.UP: {
				if (history.hasAny()) {
					val input = getInput()

					if (input.equals(history.getCurrent()))
						history.morePast()
					else {
						temporaryCommandName = input
					}

					setInput(history.getCurrent())
				}
			}

			case KeyCode.DOWN: {
				if (history.hasAny()) {
					if (history.lessPast()) {
						setInput(if (temporaryCommandName != null) temporaryCommandName else "")
					}
					else {
						setInput(history.getCurrent())
					}
				}
			}
		}
	}

}
