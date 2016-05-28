package net.namekdev.theconsole.modules

import java.nio.file.Path
import java.util.ArrayList
import java.util.List
import jdk.nashorn.api.scripting.ScriptObjectMirror
import net.namekdev.theconsole.commands.CommandManager
import net.namekdev.theconsole.commands.internal.ModuleCommand
import net.namekdev.theconsole.repl.ReplManager
import net.namekdev.theconsole.repl.instantiator.ModuleReplInstantiator
import net.namekdev.theconsole.utils.PathUtils
import net.namekdev.theconsole.utils.api.IDatabase.ISectionAccessor

class Module {
	public val String name
	public val Path entryFile
	public val Path directory
	public val String relativeEntryFilePath
	public val String relativeDirectory
	public val String variableName

	public val ISectionAccessor storage
	val registeredCommands = new ArrayList<String>
	public val ModuleContext context

	new(String name, Path entryFile, String variableName, ISectionAccessor moduleStorage) {
		this.name = name
		this.entryFile = entryFile
		this.directory = entryFile.parent
		this.relativeEntryFilePath = PathUtils.normalize(PathUtils.scriptsDir.relativize(entryFile))
		this.relativeDirectory = PathUtils.normalize(PathUtils.scriptsDir.relativize(directory))
		this.variableName = variableName
		this.storage = moduleStorage
		this.context = new ModuleContext(this)
	}

	def void refreshCommands(CommandManager commandManager, List<String> commands) {
		val toUnregister = registeredCommands.filter[cmd | !commands.contains(cmd)].toList
		val toRegister = commands.filter([cmd | !registeredCommands.contains(cmd)]).toList

		toUnregister.forEach[ cmd |
			commandManager.remove(cmd)
			registeredCommands.remove(cmd)
		]

		toRegister.forEach[ cmd |
			commandManager.put(cmd, new ModuleCommand(this, cmd))
			registeredCommands.add(cmd)
		]
	}

	/**
	 * @return {@code true} if REPL should be set
	 */
	def boolean refreshRepl(ReplManager replManager, String replName, boolean replExists) {
		if (replExists) {
			val replInstantiator = replManager.getDynamicRepl(replName)

			// if REPL is existing then remove it first because we've jost got a new JS object
			if (replInstantiator != null) {
				replManager.removeDynamicRepl(replName)
			}

			val newReplInstantiator = new ModuleReplInstantiator(this)
			replManager.putDynamicRepl(newReplInstantiator)

			return true
		}
		else {
			replManager.removeDynamicRepl(replName)
		}

		return false
	}
}