package net.namekdev.theconsole.view

import javafx.fxml.FXML
import javafx.fxml.FXMLLoader
import javafx.scene.control.TextField
import javafx.scene.layout.AnchorPane
import javafx.scene.layout.Pane
import org.eclipse.fx.ui.controls.styledtext.StyledTextArea

class ConsoleWindow extends AnchorPane {
	@FXML public Pane outputPane
	@FXML public TextField promptInput
	StyledTextArea outputTextArea


	public new() {
		val loader = new FXMLLoader(getClass().getResource("ConsoleWindow.fxml"))
		loader.setRoot(this)
		loader.setController(this)
		loader.load()

		getStylesheets().add(getClass().getResource("ConsoleWindow.css").toExternalForm())

		outputTextArea = new StyledTextArea()
		outputTextArea.editable = false
		outputTextArea.content.text = "color test"
		outputTextArea.prefWidthProperty().bind(outputPane.widthProperty())
		outputTextArea.prefHeightProperty().bind(outputPane.heightProperty())
		outputTextArea.focusTraversable = false
		outputPane.children.add(outputTextArea)
	}
}