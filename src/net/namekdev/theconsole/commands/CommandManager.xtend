package net.namekdev.theconsole.commands

import java.util.ArrayList
import java.util.List
import java.util.Map
import java.util.TreeMap
import net.namekdev.theconsole.commands.api.ICommand
import net.namekdev.theconsole.commands.internal.AliasCommand
import net.namekdev.theconsole.commands.internal.ExecCommand
import net.namekdev.theconsole.utils.api.IDatabase

/**
 * Handles all commands and command aliasing.
 */
class CommandManager {
	val Map<String, ICommand> commands = new TreeMap
	val List<String> commandNames = new ArrayList
	public val AliasManager aliases


	new(IDatabase storage) {
		val aliasStorage = storage.aliasesSection
		aliases = new AliasManager(aliasStorage)
		put("alias", new AliasCommand(aliases, aliasStorage))
		put("exec", new ExecCommand())
	}

	def get(String name) {
		return commands.get(name)
	}

	def put(String name, ICommand command) {
		commands.put(name, command)

		if (!commandNames.exists[equals(name)]) {
			commandNames.add(name)
			commandNames.sort()
		}
	}

	def remove(String name) {
		commands.remove(name)
		commandNames.removeIf[equals(name)]
	}

	def getCommandCount() {
		commands.size()
	}

	def getAllScriptNames() {
		return commandNames
	}


	def findCommandNamesStartingWith(String namePart, ArrayList<String> outNames) {
		if (namePart.length() == 0) {
			return
		}

		for (String scriptName : commandNames) {
			if (scriptName.indexOf(namePart) == 0) {
				outNames.add(scriptName)
			}
		}
	}
}