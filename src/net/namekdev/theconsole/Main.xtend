package net.namekdev.theconsole

import javafx.application.Platform
import javafx.embed.swing.JFXPanel
import javax.swing.SwingUtilities
import net.namekdev.theconsole.view.ConsoleApp
import it.sauronsoftware.junique.JUnique
import it.sauronsoftware.junique.AlreadyLockedException

class Main {
	static val MSG_OPEN = "open"

	static ConsoleApp app

	def public static main(String[] args) {
		val uniqueAppId = ConsoleApp.typeName
		try {
			JUnique.acquireLock(uniqueAppId, [msg |
				if (msg.equals(MSG_OPEN)) {
					app.show()
					return null
				}
			])
		}
		catch (AlreadyLockedException exc) {
			// one instance is already running, inform it to open but don't continue!
			JUnique.sendMessage(uniqueAppId, MSG_OPEN)
			return
		}

		SwingUtilities.invokeLater [
			// initialize JavaFX (little hack)
			new JFXPanel()

			Platform.runLater [
				val visible = args.exists[arg|arg.equals('-showOnStart')]
				app = new ConsoleApp(visible)
			]
		]
	}
}