package net.namekdev.theconsole.scripts.internal

import net.namekdev.theconsole.scripts.api.IScript
import net.namekdev.theconsole.commands.api.IAliasManager
import net.namekdev.theconsole.scripts.execution.JsUtilsProvider
import net.namekdev.theconsole.scripts.ConsoleProxy
import net.namekdev.theconsole.utils.base.IDatabase.ISectionAccessor
import java.util.List
import java.util.ArrayList
import com.eclipsesource.json.Json

class AliasScript implements IScript {
	protected IAliasManager aliasManager
	protected ISectionAccessor storage
	protected JsUtilsProvider utils
	protected ConsoleProxy console

	private ArrayList<String> tmpArray = new ArrayList<String>()

	private final static String USAGE_INFO = 'Usage:
 - alias list
 - alias remove <alias>
 - alias <alias> <command> [param, [param, [...]]]'


	new(IAliasManager aliasManager, ISectionAccessor storage, JsUtilsProvider utils, ConsoleProxy console) {
		this.aliasManager = aliasManager
		this.storage = storage
		this.utils = utils
		this.console = console
	}

	override Object run(String[] args) {
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
			}
			console.log(sb.toString())
		}
		else {
			utils.assertInfo(args.length >=2, USAGE_INFO)

			val aliasName = args.get(0)
			val aliasValue = utils.argsToString(args, 1)

			aliases.set(aliasName, aliasValue)
			aliasManager.put(aliasName, aliasValue)
		}

		if (shouldSave) {
			storage.root = aliases
			storage.save()
		}

		return null
	}

}
