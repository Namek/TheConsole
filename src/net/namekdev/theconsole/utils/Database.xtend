package net.namekdev.theconsole.utils

import java.io.FileWriter
import java.io.IOException
import java.io.File
import java.io.FileReader
import net.namekdev.theconsole.utils.base.IDatabase.ISectionAccessor
import net.namekdev.theconsole.utils.base.IDatabase
import com.eclipsesource.json.Json
import com.eclipsesource.json.JsonValue
import com.eclipsesource.json.JsonObject
import com.eclipsesource.json.ParseException

/**
 * Reads database file once. Gives a possibility to overwrite it.
 * Simple abstraction made for future security purposes.
 *
 * @author Namek
 */
class Database implements IDatabase {
	protected final String ALIASES_SECTION = "aliases"
	protected final String SCRIPTS_SECTION = "scripts"

	private File file
	public JsonObject content


	override load(String filePath) {
		file = new File(filePath)
		file.getParentFile().mkdirs()

		if (!file.exists()) {
			try {
				file.createNewFile()
			}
			catch (IOException e) {
				e.printStackTrace()
			}
		}

		var JsonValue content

		if (file.exists()) {
			val fileStream = new FileReader(file)
			try {
				content = Json.parse(fileStream).asObject
				fileStream.close()
			}
			catch (ParseException exc) {
				if (file.length > 0) {
					// TODO maybe copy file?
					exc.printStackTrace()
					this.content = Json.object()
					throw new RuntimeException("Couldn't parse " + file + ": " + exc.message, exc)
				}
			}
		}

		this.content = if (content == null) Json.object() else content.asObject
	}

	override save() {
		try {
			val stream = new FileWriter(file, false)
			stream.write(content.toString())
			stream.close()
		}
		catch (IOException e) {
			e.printStackTrace()
		}
	}

	override getSection(String section, boolean createIfDoesntExist) {
		return getSection(content, section, createIfDoesntExist)
	}

	override getAliasesSection() {
		return getSection(ALIASES_SECTION, true)
	}

	override getScriptsSection() {
		return getSection(SCRIPTS_SECTION, true)
	}

	def private SectionAccessor getSection(JsonObject root, String section, boolean createIfDoesntExist) {
		var tree = null as JsonObject

		if (createIfDoesntExist) {
			tree = JsonUtils.getOrCreateChildObject(root.asObject, section)
		}
		else {
			tree = root.get(section).asObject
		}

		return new SectionAccessor(this, tree)
	}

	static class SectionAccessor implements ISectionAccessor {
		val Database database
		public val JsonObject root

		new(Database database, JsonObject tree) {
			this.database = database
			this.root = tree
		}

		override has(String key) {
			return root.get(key) != null
		}

		override get(String key) {
			return get(key, false)
		}

		override get(String key, boolean emptyStringIfDoesntExist) {
			if (has(key))
				return root.get(key).asString()
			else
				return if (emptyStringIfDoesntExist) "" else null
		}

		override set(String key, String value) {
			root.set(key, value)
		}

		override remove(String key) {
			root.remove(key)
		}

		override save() {
			database.save()
		}

		override getSection(String section, boolean createIfDoesntExist) {
			return database.getSection(root, section, createIfDoesntExist)
		}

		// FIXME? This one's name doesn't fit in this local context but I didn't want to create
		// some weird OOP templatish or compositional abstraction for it - for now. :)
		override getGlobalStorage(String storageName) {
			return database.getSection(database.content, storageName, true)
		}
	}
}
