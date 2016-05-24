package net.namekdev.theconsole.commands

import java.util.ArrayList
import java.util.regex.Matcher
import java.util.regex.Pattern
import javafx.scene.input.KeyCode
import javafx.scene.input.KeyEvent
import net.namekdev.theconsole.commands.api.ICommand
import net.namekdev.theconsole.commands.api.ICommandLineHandler
import net.namekdev.theconsole.scripts.execution.ScriptAssertError
import net.namekdev.theconsole.state.api.IConsoleContext
import net.namekdev.theconsole.utils.PathUtils
import net.namekdev.theconsole.view.api.IConsoleOutput
import net.namekdev.theconsole.view.api.IConsoleOutputEntry
import net.namekdev.theconsole.view.api.IConsolePromptInput

class CommandLineHandler implements ICommandLineHandler {
	val CommandManager commandManager
	val AliasManager aliasManager

	var IConsoleContext consoleContext
	var IConsolePromptInput consolePrompt
	var IConsoleOutput consoleOutput

	val CommandHistory history = new CommandHistory

	val SPACE_CHAR = 32 as char
	val NEW_LINE_CHAR = 10 as char

	val paramRegex = Pattern.compile(
		'''(\d+(\.\d*)?)|([\w:/\\\.]+)|\"([^\"]*)\"|\'([^']*)\'|`([^`]*)`''',
		Pattern.UNICODE_CHARACTER_CLASS
	)

	val commandNames = new ArrayList<String>()
	var lastAddedEntry = null as IConsoleOutputEntry
	var String temporaryCommandName

	new(CommandManager commandManager) {
		this.commandManager = commandManager
		this.aliasManager = commandManager.aliases
	}

	override initContext(IConsoleContext context) {
		this.consoleContext = context
		this.consolePrompt = context.input
		this.consoleOutput = context.output
	}

	override handle(KeyEvent evt) {
		switch (evt.code) {
			case KeyCode.TAB: {
				var enableArgumentCompletion = false

				if (countSpacesInInput() == 0) {
					val completions = tryCompleteCommandName()
					if (completions.size == 1) {
						// add space
						setInput(completions.get(0) + ' ')
					}
				}
				else {
					enableArgumentCompletion = true
				}

				if (enableArgumentCompletion) {
					tryCompleteArgument()
				}

				evt.consume()
			}

			case KeyCode.ENTER: {
				val fullCommand = getInput()

				if (fullCommand.length() > 0) {
					consoleOutput.addInputEntry(fullCommand)
					setInput("")
					tryExecuteCommand(fullCommand, false)
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
				if (getInput().length() == 0) {
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

	def void setInput(String text) {
		setInput(text, -1)
	}

	def void setInput(String text, int caretPos) {
		consolePrompt.setText(text)
		consolePrompt.setCursorPosition(if (caretPos >= 0) caretPos else text.length())
	}

	def String getInput() {
		return consolePrompt.getText()
	}

	def int getInputCursorPosition() {
		return consolePrompt.cursorPosition
	}

	def int countSpacesInInput() {
		var count = 0 as int
		val str = getInput()

		for (var i = 0, val n = str.length(); i < n; i++) {
			if (str.charAt(i) == SPACE_CHAR) {
				count++
			}
		}

		return count
	}

	def tryCompleteCommandName() {
		val namePart = getInput()

		// TODO search between aliases too
		commandNames.clear()
		commandNames.ensureCapacity(commandManager.commandCount + aliasManager.aliasCount)
		commandManager.findCommandNamesStartingWith(namePart, commandNames)
		aliasManager.findAliasesStartingWith(namePart, commandNames)

		// Complete this command
		if (commandNames.size == 1) {
			// complete to this one
			val commandName = commandNames.get(0)

			if (!commandName.equals(namePart)) {
				setInput(commandName)
				lastAddedEntry = null
			}
		}

		// Complete to the common part and show options to continue
		else if (commandNames.size > 1) {
			// TODO complete to the common part
			val commonPart = findBiggestCommonPart(commandNames)

			if (commonPart.length() > 0 && !getInput().equals(commonPart)) {
				setInput(commonPart)
			}
			else {
				// Present options
				var sb = new StringBuilder('---\n')
				for (var i = 0; i < commandNames.size; i++) {
					sb.append(commandNames.get(i))

					if (i != commandNames.size-1) {
						sb.append(NEW_LINE_CHAR)
					}
				}

				val text = sb.toString()

				// Don't add the same output second time
				if (lastAddedEntry == null || lastAddedEntry.type != IConsoleOutputEntry.INPUT) {
					lastAddedEntry = consoleOutput.addTextEntry(text)
					lastAddedEntry.type = IConsoleOutputEntry.INPUT
				}
				else if (lastAddedEntry != null) {
					lastAddedEntry.setText(text)
				}
			}

		}

		// Just present command list
		else {
			val allScriptNames = commandManager.getAllScriptNames()
			val allAliasNames = aliasManager.getAllAliasNames()
			commandNames.clear()
			commandNames.addAll(allScriptNames)
			commandNames.addAll(allAliasNames)
			val sortedCommands = commandNames.sort()

			val sb = new StringBuilder('---\n')

			for (var i = 0; i < sortedCommands.size; i++) {
				sb.append(sortedCommands.get(i))

				if (i != sortedCommands.size-1) {
					sb.append(NEW_LINE_CHAR)
				}
			}

			if (lastAddedEntry != null) {
				if (!lastAddedEntry.valid) {
					lastAddedEntry = null
				}
			}

			if (lastAddedEntry == null || lastAddedEntry.type != IConsoleOutputEntry.INPUT) {
				lastAddedEntry = consoleOutput.addTextEntry(sb.toString())
				lastAddedEntry.type = IConsoleOutputEntry.INPUT
			}
			else if (lastAddedEntry != null) {
				// modify existing text entry
				lastAddedEntry.setText(sb.toString())
			}
		}

		return commandNames
	}

	private def void tryCompleteArgument() {
		val line = getInput()
		val caretPos = inputCursorPosition

		// we will tokenize and gather everything before caret position
		val matcher = paramRegex.matcher(line)
		matcher.region(0, caretPos)

		val tokens = new ArrayList<ArgToken>()

		// first token is supposed to be a command name but don't have to be
		matcher.find()
		val commandName = matcher.group
		val command = commandManager.get(commandName)
		val isCommand = command != null

		if (!isCommand) {
			tokens.add(new ArgToken(matcher))
		}

		while (matcher.find()) {
			tokens.add(new ArgToken(matcher))
		}

		var lastTokensCount = 1
		val completions = new ArrayList<String>
		var ArgToken token = null

		if (tokens.size == 0) {
			val suggestions = command.completeArgument(consoleContext, '-noargs')

			if (suggestions != null) {
				completions.addAll(suggestions)
			}
		}
		else while (completions.size == 0 && lastTokensCount <= tokens.size) {
			token = tokens.stream
				.skip(tokens.size - lastTokensCount)
				.findFirst.get

			val testArg = line.substring(token.pos, caretPos)

			if (isCommand) {
				// first ask command's owner (a module, probably) whether it can complete the argument
				val suggestions = command.completeArgument(consoleContext, testArg)

				if (suggestions != null) {
					completions.addAll(suggestions)
				}
			}

			if (completions.length == 0) {
				// no one could complete this argument, maybe it's just a full path?
				completions.addAll(PathUtils.suggestPathCompletion(testArg))
			}

			lastTokensCount++
		}

		if (completions.size == 1) {
			val sb = new StringBuilder

			if (token != null) {
				sb.append(line.substring(0, token.pos))
			}
			else {
				sb.append(line)
			}

			sb.append(completions.get(0))
			val newCaretPos = sb.length
			sb.append(line.substring(caretPos))
			setInput(sb.toString, newCaretPos)
		}
		else if (completions.size > 0) {
			// just display as text (for now)
			val text = completions.join('\n')

			if (lastAddedEntry == null || lastAddedEntry.type != IConsoleOutputEntry.INPUT) {
				lastAddedEntry = consoleOutput.addTextEntry(text)
				lastAddedEntry.type = IConsoleOutputEntry.INPUT
			}
			else if (lastAddedEntry != null) {
				// modify existing text entry
				lastAddedEntry.setText(text)
			}
		}
	}

	def void tryExecuteCommand(String fullCommand, boolean ignoreAliases) {
		var runAsJavaScript = false
		val matcher = paramRegex.matcher(fullCommand)

		if (!matcher.find()) {
			// Expression is so weird that cannot be a command, try to run it as JS code.
			runAsJavaScript = true
		}
		else {
			// Read command name
			var commandName = ""
			var commandNameEndIndex = -1

			for (var i = 1; i <= matcher.groupCount(); i++) {
				val group = matcher.group(i)

				if (group != null && group.length() > commandName.length()) {
					commandName = group
					commandNameEndIndex = matcher.end(i)
				}
			}

			// Read command arguments
			val args = new ArrayList<String>()

			while (matcher.find()) {
				var parameterValue = ""

				for (var i = 1; i <= matcher.groupCount(); i++) {
					val group = matcher.group(i)

					if (group != null && group.length() > parameterValue.length()) {
						parameterValue = group
					}
				}

				args.add(parameterValue)
			}

			// Look for command of such name
			var command = commandManager.get(commandName) as ICommand

			if (command != null) {
				// TODO validate arguments here

				var result = null as Object
				try {
					result = command.run(consoleContext, args)
				}
				catch (ScriptAssertError assertion) {
					if (assertion.isError) {
						consoleOutput.addErrorEntry(assertion.text)
					}
					else {
						consoleOutput.addTextEntry(assertion.text)
					}
					result = null
				}

				if (result != null) {
					if (result instanceof Exception) {
						consoleOutput.addErrorEntry(result.toString())
					}
					else {
						consoleOutput.addTextEntry(result + "")
					}
				}
			}
			else if (!ignoreAliases) {
				// There is no script named by `commandName` so look for aliases
				val commandStr = aliasManager.get(commandName)

				if (commandStr != null) {
					val newFullCommand = commandStr + fullCommand.substring(commandNameEndIndex)
					tryExecuteCommand(newFullCommand, true)
				}
				else {
					runAsJavaScript = true
				}
			}
			else {
				runAsJavaScript = true
			}
		}

		if (runAsJavaScript) {
			// script was not found, so try to execute it as pure JavaScript!
			val result = consoleContext.runUnscopedJs(fullCommand) as Object

			if (result instanceof Exception) {
				consoleOutput.addErrorEntry(result.toString())
			}
			else {
				consoleOutput.addTextEntry(result + "")
			}
		}
	}

	def String findBiggestCommonPart(ArrayList<String> names) {
		if (names.size == 1) {
			return names.get(0)
		}
		else if (names.size == 0) {
			return ""
		}

		var charIndex = 0 as int
		var isSearching = true

		while (isSearching) {
			val firstName = names.get(0)

			if (firstName.length() <= charIndex) {
				isSearching = false
			}

			val c = firstName.charAt(charIndex)

			for (var i = 1; i < names.size; i++) {
				val name = names.get(i)

				if (name.length() <= charIndex || name.charAt(charIndex) != c) {
					isSearching = false
				}
			}

			if (isSearching) {
				charIndex++
			}
		}

		return names.get(0).substring(0, charIndex)
	}


	private static class ArgToken {
		String text
		int pos
		int end
		int len

		new(Matcher m) {
			text = m.group
			pos = m.start
			end = m.end
			len = end - pos
		}

		override toString() {
			return #[text, pos, end].toString
		}
	}
}