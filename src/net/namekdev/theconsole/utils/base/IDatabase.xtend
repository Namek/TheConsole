package net.namekdev.theconsole.utils.base

import com.eclipsesource.json.JsonObject

interface IDatabase {
	def void load(String path)
	def void save()
	def ISectionAccessor getSection(String section, boolean createIfDoesntExist)
	def ISectionAccessor getAliasesSection()
	def ISectionAccessor getScriptsSection()


	interface ISectionAccessor {
		def JsonObject getRoot()
		def void setRoot(JsonObject root)

		def boolean has(String key)
		def String get(String key)
		def String get(String key, boolean emptyStringIfDoesntExist)
		def void set(String key, String value)
		def void remove(String key)
		def void save()
		def ISectionAccessor getSection(String section, boolean createIfDoesntExist)

		// FIXME? This one's name doesn't fit in this local context but I didn't want to create
		// some weird OOP templatish or compositional abstraction for it - for now. :)
		def ISectionAccessor getGlobalStorage(String storageName)
	}
}