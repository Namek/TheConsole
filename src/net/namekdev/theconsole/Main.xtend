package net.namekdev.theconsole

import javafx.application.Platform
import javafx.embed.swing.JFXPanel
import javax.swing.SwingUtilities
import net.namekdev.theconsole.view.ConsoleApp

class Main {
	def public static main(String[] args) {
		SwingUtilities.invokeLater [
			// initialize JavaFX (little hack)
			new JFXPanel()

			Platform.runLater [
				val visible = args.exists[arg|arg.equals('-showOnStart')]
				new ConsoleApp(visible)
			]
		]
	}
}