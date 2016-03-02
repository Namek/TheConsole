package net.namekdev.theconsole.view

import javafx.embed.swing.JFXPanel
import javafx.scene.Scene
import javafx.stage.Screen
import javax.swing.JFrame

class UndecoratedUtilityWindow extends JFrame {
	JFXPanel fxContainer

	new(Scene scene) {
		fxContainer = new JFXPanel()
		fxContainer.setScene(scene)
		getContentPane().add(fxContainer)

		val primaryScreen = Screen.primary
		val width = primaryScreen.bounds.width as int
		var height = (primaryScreen.bounds.height/2) as int
		setSize(width, height)

		type = Type.UTILITY
		undecorated = true
		alwaysOnTop = true
		defaultCloseOperation = EXIT_ON_CLOSE
	}
}