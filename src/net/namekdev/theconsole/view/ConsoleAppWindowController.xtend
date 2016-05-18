package net.namekdev.theconsole.view

import java.awt.EventQueue
import java.awt.MouseInfo
import java.awt.Robot
import java.awt.event.InputEvent
import javax.swing.JFrame
import net.namekdev.theconsole.view.api.IWindowController
import javafx.stage.Screen

package class ConsoleAppWindowController implements IWindowController {
	val JFrame window
	val robot = new Robot()


	new(JFrame window) {
		this.window = window
	}

	override setVisible(boolean visible) {
		window.visible = visible

		if (visible) {
			// weird hack that enables to re-focus window.
			// TODO: probably won't work properly on multi-screen env
			EventQueue.invokeLater [
				window.toFront()

				try {
					// remember the last location of mouse
					val oldMouseLocation = MouseInfo.getPointerInfo().getLocation()

					// simulate a mouse click on title bar of window
					robot.mouseMove(window.getX() + 10, window.getY() + window.getHeight() - 10)
					robot.mousePress(InputEvent.BUTTON1_DOWN_MASK)
					robot.mouseRelease(InputEvent.BUTTON1_DOWN_MASK)

					// move mouse to old location
					robot.mouseMove(oldMouseLocation.getX() as int, oldMouseLocation.getY() as int)
				}
				catch (Exception ex) { }
			]
		}

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

	def void setScreen(int index) {
		val screens = Screen.screens

		if (screens.size > index+1) {
			return
		}

		val screen = Screen.screens.get(index)
		screen.bounds

		// TODO change position and resolution

//		screen.bounds.
	}

	def int getScreenCount() {
		Screen.screens.size
	}
}