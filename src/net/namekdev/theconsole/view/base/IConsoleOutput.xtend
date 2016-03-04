package net.namekdev.theconsole.view.base

interface IConsoleOutput {
	def IConsoleOutputEntry addTextEntry(String text)
	def IConsoleOutputEntry addErrorEntry(String text)
	def IConsoleOutputEntry addInputEntry(String text)
}