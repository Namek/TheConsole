package net.namekdev.theconsole.view

import java.util.logging.Level
import java.util.logging.Logger
import javafx.scene.Scene
import javafx.scene.control.TextField
import javafx.scene.layout.BorderPane
import javax.swing.JFrame
import org.jnativehook.GlobalScreen
import org.jnativehook.NativeInputEvent
import org.jnativehook.keyboard.NativeKeyEvent
import org.jnativehook.keyboard.NativeKeyListener

class ConsoleApp implements NativeKeyListener {
	JFrame hostWindow
	Scene scene

	new() {
		initScene()
		hostWindow = new UndecoratedUtilityWindow(scene)

		val nativeHookLogger = Logger.getLogger(typeof(GlobalScreen).getPackage().getName())
		nativeHookLogger.setLevel(Level.WARNING)
		nativeHookLogger.setUseParentHandlers(false)
		GlobalScreen.registerNativeHook()
		GlobalScreen.addNativeKeyListener(this)

		hostWindow.setVisible(true)
	}

	def initScene() {
		val root = new BorderPane()
		scene = new Scene(root)
		scene.getStylesheets().add(getClass().getResource("/net/namekdev/theconsole/view/ConsoleWindow.css").toExternalForm())

		val commandPrompt = new TextField()
		root.bottom = commandPrompt
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