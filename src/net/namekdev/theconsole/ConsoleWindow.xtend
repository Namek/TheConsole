package net.namekdev.theconsole

import com.sun.glass.ui.Screen
import javafx.scene.Scene
import javafx.stage.Stage
import javafx.stage.StageStyle
import javafx.scene.layout.BorderPane
import javafx.application.Platform

class ConsoleWindow {
	Stage stage

	new(Stage stage) {
		this.stage = stage

		val root = new BorderPane()
		val primaryScreen = Screen.getMainScreen()
		val width = primaryScreen.getWidth()
		var height = primaryScreen.getHeight()/2

		val scene = new Scene(root, width, height)
		scene.getStylesheets().add(getClass().getResource("/net/namekdev/theconsole/application.css").toExternalForm())
		stage.initStyle(StageStyle.UNDECORATED)
		stage.setAlwaysOnTop(true)
		stage.setScene(scene)
		stage.setX(0)
		stage.setY(0)
	}

	def setVisible(boolean show) {
		Platform.runLater [
			if (!stage.showing && show) {
				stage.show()
			}
			else if (stage.showing && !show) {
				stage.hide()
			}
		]
	}

	def isVisible() {
		return stage.showing
	}
}