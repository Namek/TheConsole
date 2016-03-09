package net.namekdev.theconsole.view

import javax.swing.JFrame
import net.namekdev.theconsole.view.api.IWindowController

package class ConsoleAppWindowController implements IWindowController {
	val JFrame window

	new(JFrame window) {
		this.window = window
	}

	override setVisible(boolean visible) {
		window.visible = visible
	}

	override isVisible() {
		return window.visible
	}

	override setPosition(int x, int y) {
		window.setLocation(x, y)
	}

	override getX() {
		return window.x
	}

	override getY() {
		return window.y
	}

	override setSize(int width, int height) {
		window.setSize(width, height)
	}

	override getWidth() {
		return window.width
	}

	override getHeight() {
		return window.height
	}

	override getOpacity() {
		return window.opacity
	}

	override setOpacity(float opacity) {
		window.opacity = opacity
	}

}