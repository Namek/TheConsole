package net.namekdev.theconsole

import javafx.application.Application
import javafx.stage.Stage
import org.jnativehook.NativeInputEvent
import org.jnativehook.keyboard.NativeKeyEvent
import org.jnativehook.keyboard.NativeKeyListener
import java.util.logging.Logger
import org.jnativehook.GlobalScreen
import java.util.logging.Level
import javafx.application.Platform
import com.sun.javafx.application.PlatformImpl

class Main extends Application implements NativeKeyListener {
	ConsoleWindow console

	override start(Stage primaryStage) {
		val nativeHookLogger = Logger.getLogger(typeof(GlobalScreen).getPackage().getName())
		nativeHookLogger.setLevel(Level.WARNING)
		nativeHookLogger.setUseParentHandlers(false)

		try {
			Platform.implicitExit = false

			console = new ConsoleWindow(primaryStage)
			console.setVisible(true)
			GlobalScreen.registerNativeHook()
			GlobalScreen.addNativeKeyListener(this)
		}
		catch (Exception e) {
			e.printStackTrace()
			System.exit(1)
		}
	}

	def public static void main(String[] args) {
		launch(args)
	}


	override nativeKeyPressed(NativeKeyEvent evt) {
		if (isConsoleToggleEvent(evt)) {
			val show = !console.isVisible()

			console.setVisible(show)
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