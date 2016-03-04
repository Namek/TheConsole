package net.namekdev.theconsole.scripts.base

import java.util.ArrayList

interface IScriptManager {
	def IScript get(String name)
	def ArrayList<String> getAllScriptNames()
	def Object runJs(String string)
	def int getScriptCount()
	def void findScriptNamesStartingWith(String string, ArrayList<String> strings)
}