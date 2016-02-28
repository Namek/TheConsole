package net.namekdev.theconsole;

import com.sun.glass.ui.Screen;

import javafx.application.Application;
import javafx.scene.Scene;
import javafx.scene.layout.BorderPane;
import javafx.stage.Stage;
import javafx.stage.StageStyle;


public class Main extends Application {
	@Override
	public void start(Stage primaryStage) {
		try {
			BorderPane root = new BorderPane();

			Screen primaryScreen = Screen.getMainScreen();
			int width = primaryScreen.getWidth();
			int height = primaryScreen.getHeight()/2;

			Scene scene = new Scene(root, width, height);
			scene.getStylesheets().add(getClass().getResource("/net/namekdev/theconsole/application.css").toExternalForm());
			primaryStage.initStyle(StageStyle.TRANSPARENT);
			primaryStage.setAlwaysOnTop(true);
			primaryStage.setScene(scene);
			primaryStage.show();
			primaryStage.setX(0);
			primaryStage.setY(0);
		}
		catch(Exception e) {
			e.printStackTrace();
		}
	}

	public static void main(String[] args) {
		launch(args);
	}
}
