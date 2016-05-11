package net.namekdev.theconsole.scripts

import net.namekdev.theconsole.view.api.IConsoleOutput
import net.namekdev.theconsole.view.api.IWindowController

class ConsoleProxy {
	IConsoleOutput consoleOutput
	IWindowController windowController

	new(IConsoleOutput consoleOutput, IWindowController windowController) {
		this.consoleOutput = consoleOutput
		this.windowController = windowController
	}

	def void log(String text) {
		consoleOutput.addTextEntry(text);
	}

	/**
	 *
	 * @param text
	 * @param colorHex Hex in format 0xRRGGBB, example red: 0xFF0000.
	 */
	def void log(String text, int colorHex) {
		consoleOutput.addTextEntry(text, colorHex)
	}

//	def void error(String text) {
//		consoleOutput.addErrorEntry(text)
//	}

	def void clear() {
		consoleOutput.clear()
	}

	def void hide() {
		windowController.setVisible(false)
	}
}