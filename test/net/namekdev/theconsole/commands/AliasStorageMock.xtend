package net.namekdev.theconsole.commands

import com.eclipsesource.json.JsonObject
import net.namekdev.theconsole.utils.api.IDatabase

class AliasStorageMock implements IDatabase.ISectionAccessor {
	val json = new JsonObject()

	override getRoot() {
		return json
	}

	override setRoot(JsonObject root) {
		throw new IllegalStateException("should not be called in mock")
	}

	override has(String key) {
		throw new IllegalStateException("should not be called in mock")
	}

	override get(String key) {
		throw new IllegalStateException("should not be called in mock")
	}

	override get(String key, boolean emptyStringIfDoesntExist) {
		throw new IllegalStateException("should not be called in mock")
	}

	override set(String key, String value) {
		throw new IllegalStateException("should not be called in mock")
	}

	override remove(String key) {
		throw new IllegalStateException("should not be called in mock")
	}

	override save() {
		// it's OK
	}

	override getSection(String section, boolean createIfDoesntExist) {
		throw new IllegalStateException("should not be called in mock")
	}

	override getGlobalStorage(String storageName) {
		throw new IllegalStateException("should not be called in mock")
	}
}