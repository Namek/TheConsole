package net.namekdev.theconsole.view.components

import javafx.beans.value.ChangeListener
import javafx.event.Event
import javafx.event.EventHandler
import javafx.fxml.FXML
import javafx.fxml.FXMLLoader
import javafx.scene.control.Tab
import javafx.scene.control.TabPane
import javafx.scene.layout.AnchorPane
import net.namekdev.theconsole.state.ConsoleContext
import net.namekdev.theconsole.state.api.IConsoleContextManager
import javafx.application.Platform
import javafx.scene.input.InputEvent
import javafx.scene.input.KeyEvent
import javafx.scene.input.KeyCode
import java.util.regex.Pattern

class ConsoleView extends AnchorPane {
	IConsoleContextManager consoleContextManager
	@FXML public TabPane tabPane


	public new() {
	}

	def void init(IConsoleContextManager consoleContextManager) {
		this.consoleContextManager = consoleContextManager

		val loader = new FXMLLoader(getClass().getResource("ConsoleView.fxml"))
		loader.setRoot(this)
		loader.setController(this)
		loader.load()

		getStylesheets().add(getClass().getResource("ConsoleView.css").toExternalForm())

		tabPane.getSelectionModel().selectedItemProperty.addListener(onSwitchTabHandler)

		addEventHandler(KeyEvent.KEY_PRESSED, onKeyPressHandler)
	}

	def createTab() {
		val tab = new ConsoleTab()
		val ctx = consoleContextManager.createContext(tab.consolePromptInput, tab.consoleOutput)
		tab.context = ctx

		tab.onCloseRequest = onTabCloseRequestHandler

		// determine name for new tab
		{
			val numberedTabRegex = Pattern.compile("tab\\s*(\\d+)")
			val tabNumbers = tabPane.tabs
				.map[(it as ConsoleTab).headerText]
				.map[numberedTabRegex.matcher(it.toLowerCase)]
				.filter[it.find() && it.groupCount == 1]
				.map[it.group(1)].map[Integer.parseInt(it)]
				.sort

			val newTabNumber = if (tabNumbers.empty) 1 else tabNumbers.last + 1
			tab.headerText = "Tab " + newTabNumber
		}

		tabPane.tabs.add(tab)

		return tab
	}

	def closeCurrentTab() {
		val tab = tabPane.selectionModel.selectedItem as ConsoleTab
		consoleContextManager.destroyContext(tab.context)
		tabPane.tabs.remove(tab)
	}

	def void onClosingTab(ConsoleContext ctx) {
		consoleContextManager.destroyContext(ctx)
	}

	val ChangeListener<Tab> onSwitchTabHandler = [ov, oldTab, newTab |
		val tab = newTab as ConsoleTab
		consoleContextManager.currentTabByContext = tab.context

		Platform.runLater[ tab.focusInput() ]
	]

	val EventHandler<Event> onTabCloseRequestHandler = [evt|
		if (tabPane.tabs.size < 2) {
			// don't close the last one!
			evt.consume()
			return
		}

		val tab = evt.source as ConsoleTab
		consoleContextManager.destroyContext(tab.context)
	]

	val EventHandler<KeyEvent> onKeyPressHandler = [evt|
		if (evt.controlDown && evt.code == KeyCode.W) {
			if (tabPane.tabs.length > 1) {
				closeCurrentTab()
			}
		}

		if (evt.controlDown && evt.code == KeyCode.T) {
			val newTab = createTab()
			tabPane.selectionModel.select(newTab)
		}
	]
}