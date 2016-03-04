package net.namekdev.theconsole.commands

import java.util.Stack

class CommandHistory {
	Stack<String> commands = new Stack<String>()

	/**
	 * Stack position.
	 */
	int pointer = 0


	def void save(String command) {
		commands.add(command)
	}

	def boolean hasAny() {
		return commands.size() > 0
	}

	def void morePast() {
		pointer = Math.min(pointer + 1, commands.size() - 1)
	}

	def boolean lessPast() {
		val prevPointer = pointer
		pointer = Math.max(pointer - 1, 0)

		return prevPointer == 0 && pointer == 0
	}

	def void resetPointer() {
		pointer = 0
	}

	def String getCurrent() {
		return commands.get(commands.size() - pointer - 1)
	}
}
