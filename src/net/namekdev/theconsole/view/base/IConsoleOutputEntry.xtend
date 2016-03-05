package net.namekdev.theconsole.view.base

interface IConsoleOutputEntry {
	public static val INPUT = 1
	public static val OUTPUT = 2
	public static val OUTPUT_ERROR = 3

	def boolean isValid()

	def void setText(String text)
	def String getText()

	def void setType(int type)
	def int getType()
}