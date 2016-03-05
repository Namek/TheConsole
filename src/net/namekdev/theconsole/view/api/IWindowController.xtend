package net.namekdev.theconsole.view.api


interface IWindowController {
	def void setVisible(boolean visible)
	def boolean isVisible()

	def void setPosition(int x, int y)
	def int getX()
	def int getY()

	def void setSize(int width, int height)
	def int getWidth()
	def int getHeight()

	def int getScreenWidth()
	def int getScreenHeight()

	def short getOpacity()
	def void setOpacity(short opacity)
}