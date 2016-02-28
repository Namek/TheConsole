package net.namekdev.theconsole

import com.sun.glass.ui.Screen
import javafx.application.Application
import javafx.scene.Scene
import javafx.scene.layout.BorderPane
import javafx.stage.Stage
import javafx.stage.StageStyle

class Main extends Application {
	override start(Stage primaryStage) {
		try {
			val root = new BorderPane()
			val primaryScreen = Screen.getMainScreen()
			val width = primaryScreen.getWidth()
			var height = primaryScreen.getHeight()/2

			val scene = new Scene(root, width, height)
			scene.getStylesheets().add(getClass().getResource("/net/namekdev/theconsole/application.css").toExternalForm())
			primaryStage.initStyle(StageStyle.TRANSPARENT)
			primaryStage.setAlwaysOnTop(true)
			primaryStage.setScene(scene)
			primaryStage.show()
			primaryStage.setX(0)
			primaryStage.setY(0)
		}
		catch(Exception e) {
			e.printStackTrace()
		}
	}

	def public static void main(String[] args) {
		launch(args)
	}
}