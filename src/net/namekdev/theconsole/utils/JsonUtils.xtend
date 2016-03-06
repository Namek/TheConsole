package net.namekdev.theconsole.utils

import com.eclipsesource.json.JsonValue
import com.eclipsesource.json.Json
import com.eclipsesource.json.JsonObject

abstract class JsonUtils {
	def static JsonObject getOrCreateChildObject(JsonObject root, String key) {
		var tree = root.asObject().get(key)

		if (tree == null) {
			tree = Json.object
			root.add(key, tree)
		}

		return tree.asObject
	}
}
