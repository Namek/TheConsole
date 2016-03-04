package net.namekdev.theconsole.view

import java.util.logging.Level
import java.util.logging.Logger
import javafx.scene.Scene
import javax.swing.JFrame
import net.namekdev.theconsole.commands.AliasManager
import net.namekdev.theconsole.commands.CommandLineService
import net.namekdev.theconsole.commands.base.IAliasManager
import net.namekdev.theconsole.scripts.JsScriptManager
import net.namekdev.theconsole.scripts.base.IScriptManager
import org.jnativehook.GlobalScreen
import org.jnativehook.NativeInputEvent
import org.jnativehook.keyboard.NativeKeyEvent
import org.jnativehook.keyboard.NativeKeyListener

class ConsoleApp implements NativeKeyListener {
	JFrame hostWindow
	ConsoleWindow consoleWindow
	IScriptManager scriptManager
	IAliasManager aliasManager


	new() {
		consoleWindow = new ConsoleWindow()
		hostWindow = new UndecoratedUtilityWindow(new Scene(consoleWindow))
		hostWindow.opacity = 0.85f

		scriptManager = new JsScriptManager
		aliasManager = new AliasManager
		val consolePrompt = consoleWindow.consolePromptInput
		val consoleOutput = consoleWindow.consoleOutput
		new CommandLineService(consolePrompt, consoleOutput, scriptManager, aliasManager)

		val nativeHookLogger = Logger.getLogger(typeof(GlobalScreen).getPackage().getName())
		nativeHookLogger.setLevel(Level.WARNING)
		nativeHookLogger.setUseParentHandlers(false)
		GlobalScreen.registerNativeHook()
		GlobalScreen.addNativeKeyListener(this)

		hostWindow.setVisible(true)
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