package net.namekdev.theconsole.commands.api

import java.util.ArrayList

interface IAliasManager {
	def String get(String aliasName)
	def ArrayList<String> getAllAliasNames()
	def int getAliasCount()
	def void findAliasesStartingWith(String string, ArrayList<String> strings)
}