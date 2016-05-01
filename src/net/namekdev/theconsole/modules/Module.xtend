package net.namekdev.theconsole.modules

import java.nio.file.Path
import java.util.ArrayList
import java.util.List
import net.namekdev.theconsole.commands.CommandManager
import net.namekdev.theconsole.commands.internal.ModuleCommand

class Module {
	public val Path entryFile
	public val Path directory
	public val String relativeDirectory
	public val String variableName

	val registeredCommands = new ArrayList<String>

	new(Path entryFile, String relativeDirectory, String variableName) {
		this.entryFile = entryFile
		this.directory = entryFile.parent
		this.relativeDirectory = relativeDirectory
		this.variableName = variableName
	}

	def void refreshCommands(CommandManager commandManager, List<String> commands) {
		val toUnregister = registeredCommands.filter[cmd | !commands.contains(cmd)]
		val toRegister = commands.filter([cmd | !registeredCommands.contains(cmd)])

		toUnregister.forEach[ cmd |
			commandManager.remove(cmd)
			registeredCommands.remove(cmd)
		]

		toRegister.forEach[ cmd |
			commandManager.put(cmd, new ModuleCommand(this, cmd))
			registeredCommands.add(cmd)
		]
	}
}