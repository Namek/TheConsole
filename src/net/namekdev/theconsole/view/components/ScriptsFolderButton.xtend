package net.namekdev.theconsole.view.components

import com.pepperonas.fxiconics.FxIconicsLabel
import com.pepperonas.fxiconics.MaterialColor
import com.pepperonas.fxiconics.cmd.FxFontCommunity
import javafx.scene.Cursor
import javafx.scene.control.Tooltip
import javafx.scene.input.MouseEvent
import javafx.scene.layout.Pane

class ScriptsFolderButton extends Pane {
	val btnColor = MaterialColor.INDIGO_500
	val btnClickColor = MaterialColor.INDIGO_400
	val btnHoverColor = MaterialColor.INDIGO_100

	val FxIconicsLabel icon

	new() {
		icon = new FxIconicsLabel.Builder(FxFontCommunity.Icons.cmd_folder_download)
			.size(24)
			.color(btnColor)
			.build() as FxIconicsLabel

		children.add(icon)

		icon.cursor = Cursor.HAND

		icon.hoverProperty.addListener [
			val isHovered = icon.hover
			val color = (if (isHovered) btnHoverColor else btnColor)
			setColor(color)
		]
		icon.addEventHandler(MouseEvent.MOUSE_PRESSED, [evt |
			setColor(btnClickColor)
		])
		icon.addEventHandler(MouseEvent.MOUSE_RELEASED, [evt |
			setColor(btnColor)
		])

		icon.tooltip = new Tooltip("open scripts")
		icon.tooltip.setStyle("-fx-font-size: 14")
	}

	private def void setColor(String color) {
		icon.setStyle("-fx-text-fill: " + color)
	}
}