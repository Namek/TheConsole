package net.namekdev.theconsole.commands

import java.util.ArrayList
import java.util.List
import java.util.Map
import java.util.TreeMap

class AliasCollection {
	private var Map<String, String> aliases = new TreeMap<String, String>()
	private var ArrayList<String> aliasNames = new ArrayList<String>()


	new() {
	}

	new(Map<String, String> aliases) {
		this.aliases.putAll(aliases)
	}

	def get(String aliasName) {
		return aliases.get(aliasName)
	}

	def void put(String aliasName, String command) {
		if (!aliases.containsKey(aliasName)) {
			aliasNames.add(aliasName)
			aliasNames.sort()
		}

		aliases.put(aliasName, command)
	}

	def void remove(String aliasName, String command) {
		aliasNames.removeIf([name | aliasName.equals(name)])
		aliases.remove(aliasName)
	}

	def boolean has(String aliasName) {
		return aliases.containsKey(aliasName)
	}

	def getAllAliasNames() {
		return aliasNames
	}

	def getAliasCount() {
		return aliasNames.size
	}

	def void findAliasesStartingWith(String aliasNamePart, List<String> outAliases) {
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