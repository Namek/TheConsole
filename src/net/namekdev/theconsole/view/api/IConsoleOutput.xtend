package net.namekdev.theconsole.view.api

interface IConsoleOutput {
	def IConsoleOutputEntry addTextEntry(String text)
	def IConsoleOutputEntry addTextEntry(String text, int colorHex)
	def IConsoleOutputEntry addErrorEntry(String text)
	def IConsoleOutputEntry addInputEntry(String text)
	def void clear()
}