package net.namekdev.theconsole.commands.api

import java.util.List

interface IAliasManager {

	/**
	 * Gets code for given alias.
	 *
	 * @return returns {@code null} if there is no alias of given name
	 */
	def String get(String aliasName)

	def void put(String aliasName, String command)

	def void remove(String aliasName, String command)

	def boolean has(String aliasName)

	def List<String> getAllAliasNames()
	def int getAliasCount()
	def void findAliasesStartingWith(String string, List<String> strings)
}