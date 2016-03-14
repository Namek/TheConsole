package net.namekdev.theconsole.view

import java.util.logging.Level
import java.util.logging.Logger
import javafx.scene.Scene
import javax.swing.JFrame
import net.namekdev.theconsole.state.AppStateManager
import net.namekdev.theconsole.state.api.IConsoleContextManager
import net.namekdev.theconsole.view.components.ConsoleView
import org.jnativehook.GlobalScreen
import org.jnativehook.NativeInputEvent
import org.jnativehook.keyboard.NativeKeyEvent
import org.jnativehook.keyboard.NativeKeyListener

class ConsoleApp implements NativeKeyListener {
	val IConsoleContextManager appStateManager
	val JFrame hostWindow
	val ConsoleView consoleView


	new() {
		consoleView = new ConsoleView
		hostWindow = new UndecoratedUtilityWindow(new Scene(consoleView))
		val windowController = new ConsoleAppWindowController(hostWindow)
		appStateManager = new AppStateManager(windowController)
		consoleView.init(appStateManager)
		consoleView.createTab()


		// TODO to be removed in the future when default settings will be available
		windowController.setOpacity(0.85f)
		windowController.visible = true

		val nativeHookLogger = Logger.getLogger(typeof(GlobalScreen).getPackage().getName())
		nativeHookLogger.setLevel(Level.WARNING)
		nativeHookLogger.setUseParentHandlers(false)
		GlobalScreen.registerNativeHook()
		GlobalScreen.addNativeKeyListener(this)
	}


	override nativeKeyPressed(NativeKeyEvent evt) {
		if (isConsoleToggleEvent(evt)) {
			val show = !hostWindow.isVisible()

			hostWindow.setVisible(show)
			consumeEvent(evt)
		}
	}

	override nativeKeyReleased(NativeKeyEvent evt) {
		if (isConsoleToggleEvent(evt)) {
			consumeEvent(evt)
		}
	}

	override nativeKeyTyped(NativeKeyEvent evt) {
	}

	def private boolean isConsoleToggleEvent(NativeKeyEvent evt) {
		return evt.getKeyCode() == NativeKeyEvent.VC_BACKQUOTE
			&& (evt.getModifiers() == NativeKeyEvent.CTRL_L_MASK)
	}

	def private void consumeEvent(NativeKeyEvent evt) {
		try {
			val f = typeof(NativeInputEvent).getDeclaredField("reserved")
			f.setAccessible(true)
			f.setShort(evt, 0x01 as short)
		}
		catch (Exception e) {
			e.printStackTrace()
		}
	}
}