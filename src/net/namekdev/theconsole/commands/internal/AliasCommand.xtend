package net.namekdev.theconsole.commands.internal

import com.eclipsesource.json.Json
import java.util.ArrayList
import net.namekdev.theconsole.commands.api.ICommand
import net.namekdev.theconsole.state.api.IConsoleContext
import net.namekdev.theconsole.utils.api.IDatabase.ISectionAccessor
import net.namekdev.theconsole.commands.AliasCollection

class AliasCommand implements ICommand {
	protected AliasCollection aliases
	protected ISectionAccessor storage

	private ArrayList<String> tmpArray = new ArrayList<String>()

	private final static String USAGE_INFO = 'Usage:
 - alias list
 - alias remove <alias>
 - alias <alias> <command> [param, [param, [...]]]'


	new(AliasCollection aliases, ISectionAccessor storage) {
		this.aliases = aliases
		this.storage = storage
	}

	override Object run(IConsoleContext executionContext, String[] args) {
		val utils = executionContext.jsUtils
		val console = executionContext.proxy

		utils.assertInfo(args.length != 0, USAGE_INFO)

		var aliases = storage.root.asObject

		if (aliases == null) {
			aliases = Json.object()
		}

		var shouldSave = true

		if (args.get(0).equals("remove")) {
			utils.assertError(args.length == 2, "Usage: alias remove <name>")

			aliases.remove(args.get(1))
		}
		else if (args.get(0).equals("list")) {
			utils.assertInfo(aliases.size > 0, "There is no even a single alias!")

			shouldSave = false

			tmpArray.clear()
			tmpArray.ensureCapacity(aliases.size)

			aliases.names.forEach([name | tmpArray.add(name)])
			tmpArray.sort()

			val sb = new StringBuilder()
			for (var i = 0, val n = tmpArray.size; i < n; i++) {
				val name = tmpArray.get(i)
				val alias = aliases.get(name)

				sb.append(name)
				sb.append(": ")
				sb.append(alias.asString())

				if (i != n-1) {
					sb.append('\n')
				}
			}
			console.log(sb.toString())
		}
		else {
			utils.assertInfo(args.length >=2, USAGE_INFO)

			val aliasName = args.get(0)
			val aliasValue = utils.argsToString(args, 1)

			aliases.set(aliasName, aliasValue)
			this.aliases.put(aliasName, aliasValue)
		}

		if (shouldSave) {
			storage.root = aliases
			storage.save()
		}

		return null
	}

	override completeArgument(IConsoleContext executionContext, String testArgument) {
		throw new UnsupportedOperationException("TODO: try to complete aliases?")
	}
}
