package net.namekdev.theconsole.commands.api

interface ICommandLineUtils {
	def void setInputEntry(String text)
	def void setInput(String text)
	def void setInput(String text, int caretPos)
	def String getInput()
	def int getInputCursorPosition()
	def int countSpacesInInput()
}