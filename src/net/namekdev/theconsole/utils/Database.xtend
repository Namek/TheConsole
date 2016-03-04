package net.namekdev.theconsole.utils

import java.io.FileWriter
import java.io.IOException
import java.io.File
import java.io.FileReader
import net.namekdev.theconsole.utils.base.IDatabase.ISectionAccessor
import net.namekdev.theconsole.utils.base.IDatabase

/**
 * Reads database file once. Gives a possibility to overwrite it.
 * Simple abstraction made for future security purposes.
 *
 * @author Namek
 */
public class Database implements IDatabase {
	protected final String ALIASES_SECTION = "aliases";
	protected final String SCRIPTS_SECTION = "scripts";

	private File file;
//	public JsonValue content;


	new(String filePath) {
		file = new File(filePath);
		file.getParentFile().mkdirs();

		if (!file.exists()) {
			try {
				file.createNewFile();
			}
			catch (IOException e) {
				e.printStackTrace();
			}
		}

		try {
			/*if (file.exists()) {
				val fileStream = new FileReader(file)
				val reader = new JsonReader()
				content = reader.parse(fileStream)
				fileStream.close()
			}

			if (content == null) {
				content = new JsonValue(ValueType.object)
			}*/
		}
		catch (IOException e) {
			e.printStackTrace();
		}
	}

	override save() {
		try {
			/*val stream = new FileWriter(file, false)
			stream.write(content.toString())
			stream.close()*/
		}
		catch (IOException e) {
			e.printStackTrace()
		}
	}

	override getSection(String section, boolean createIfDoesntExist) {
		return null //TODO
//		return getSection(content, section, createIfDoesntExist);
	}

	override getAliasesSection() {
		return getSection(ALIASES_SECTION, true);
	}

	override getScriptsSection() {
		return getSection(SCRIPTS_SECTION, true);
	}

	/*def private SectionAccessor getSection(JsonValue root, String section, boolean createIfDoesntExist) {
		var tree = null as JsonValue

		if (createIfDoesntExist) {
			tree = JsonUtils.getOrCreateChild(root, section, ValueType.object)
		}
		else {
			tree = root.get(section)
		}

		return new SectionAccessor(tree)
	}*/

	// TODO
	static class SectionAccessor implements ISectionAccessor {
		/*public final JsonValue root;

		SectionAccessor(JsonValue tree) {
			this.root = tree;
		}*/

		override has(String key) {
			return false
//			return root.has(key)
		}

		override get(String key) {
			return get(key, false)
		}

		override get(String key, boolean emptyStringIfDoesntExist) {
			return if (emptyStringIfDoesntExist) "" else null
//			return root.has(key) ? root.get(key).asString() : (emptyStringIfDoesntExist ? "" : null);
		}

		override set(String key, String value) {
//			JsonValue tree = JsonUtils.getOrCreateChild(root, key, ValueType.stringValue)
//			tree.set(value)
		}

		override remove(String key) {
//			if (root.has(key)) {
//				root.remove(key)
//			}
		}

		override save() {
//			Database.this.save()
		}

		override getSection(String section, boolean createIfDoesntExist) {
			return null
//			return Database.this.getSection(root, section, createIfDoesntExist);
		}

		// FIXME? This one's name doesn't fit in this local context but I didn't want to create
		// some weird OOP templatish or compositional abstraction for it - for now. :)
		override getGlobalStorage(String storageName) {
//			return Database.this.getSection(content, storageName, true);
		}
	}
}
