package net.namekdev.theconsole.commands

import net.namekdev.theconsole.commands.api.IAliasManager
import java.util.ArrayList
import java.util.Map
import java.util.TreeMap
import net.namekdev.theconsole.utils.base.IDatabase.ISectionAccessor
import java.util.List

class AliasManager implements IAliasManager {
	private var Map<String, String> aliases = new TreeMap<String, String>()
	private var ArrayList<String> aliasNames = new ArrayList<String>()


	new(ISectionAccessor aliasStorage) {
		val root = aliasStorage.root

		if (root.size == 0) {
			// probably empty
			return
		}

		val aliases = root.asObject
		aliases.forEach([node |
			put(node.name, node.value.asString())
		])
	}

	override get(String aliasName) {
		return aliases.get(aliasName)
	}

	override put(String aliasName, String command) {
		if (!aliases.containsKey(aliasName)) {
			aliasNames.add(aliasName)
			aliasNames.sort()
		}

		aliases.put(aliasName, command)
	}

	override remove(String aliasName, String command) {
		aliasNames.removeIf([name | aliasName.equals(name)])
		aliases.remove(aliasName)
	}

	override has(String aliasName) {
		return aliases.containsKey(aliasName)
	}

	override getAllAliasNames() {
		return aliasNames
	}

	override getAliasCount() {
		return aliasNames.size
	}

	override findAliasesStartingWith(String aliasNamePart, List<String> outAliases) {
		if (aliasNamePart.length() == 0) {
			return
		}

		for (String aliasName : aliasNames) {
			if (aliasName.indexOf(aliasNamePart) == 0) {
				outAliases.add(aliasName)
			}
		}
	}
}