package net.namekdev.theconsole.scripts.api

import java.util.ArrayList

interface IScriptManager {
	def IScript get(String name)

	/**
	 * Get internal array for performance reasons. Do not modify it!
	 */
	def ArrayList<String> getAllScriptNames()

	/**
	 * Run JavaScript code in new scope within given context.
	 */
	def Object runUnscopedJs(String code)

	/**
	 * Run JavaScript code without creating any scope and getting any additional context.
	 */
	def Object runJs(String code, Object[] args, Object context)

	def int getScriptCount()

	def void findScriptNamesStartingWith(String namePart, ArrayList<String> outNames)
}