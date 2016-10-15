package net.namekdev.theconsole.commands

import com.eclipsesource.json.JsonObject
import java.util.List
import net.namekdev.theconsole.utils.api.IDatabase.ISectionAccessor

class AliasStorage {
	private val ISectionAccessor storage
	private val JsonObject storageRoot


	new(ISectionAccessor storage) {
		this.storage = storage
		this.storageRoot = storage.root
	}

	def get(String aliasName) {
		val node = storageRoot.asObject.get(aliasName)

		if (node == null)
			return null

		return node.asString
	}

	def void put(String aliasName, String command) {
		storageRoot.asObject.add(aliasName, command)
	}

	def void remove(String aliasName) {
		storageRoot.asObject.remove(aliasName)
	}

	def boolean has(String aliasName) {
		return storageRoot.asObject.get(aliasName) != null
	}

	def String[] getAllAliasNames() {
		return storageRoot.asObject
			.map[node | node.name]
			.sort()
	}

	def getAliasCount() {
		return storageRoot.size
	}

	def void findAliasesStartingWith(String aliasNamePart, List<String> outAliases) {
		if (aliasNamePart.length() == 0) {
			return
		}

		storageRoot.asObject.forEach[node |
			val aliasName = node.name
			if (aliasName.indexOf(aliasNamePart) === 0) {
				outAliases.add(aliasName)
			}
		]
	}

	def save() {
		storage.save()
	}
}