package net.namekdev.theconsole.view

import java.io.IOException
import java.io.OutputStream
import java.io.PrintWriter
import java.util.logging.Level
import java.util.logging.Logger
import javafx.scene.Scene
import javax.swing.JFrame
import net.namekdev.theconsole.commands.AliasManager
import net.namekdev.theconsole.commands.CommandLineService
import net.namekdev.theconsole.commands.api.IAliasManager
import net.namekdev.theconsole.scripts.ConsoleProxy
import net.namekdev.theconsole.scripts.JsScriptManager
import net.namekdev.theconsole.scripts.api.IScriptManager
import net.namekdev.theconsole.scripts.execution.JsUtilsProvider
import net.namekdev.theconsole.scripts.internal.AliasScript
import net.namekdev.theconsole.scripts.internal.ExecScript
import net.namekdev.theconsole.utils.Database
import net.namekdev.theconsole.utils.PathUtils
import net.namekdev.theconsole.utils.base.IDatabase
import org.jnativehook.GlobalScreen
import org.jnativehook.NativeInputEvent
import org.jnativehook.keyboard.NativeKeyEvent
import org.jnativehook.keyboard.NativeKeyListener

class ConsoleApp implements NativeKeyListener {
	JFrame hostWindow
	ConsoleView consoleView
	IDatabase database
	JsUtilsProvider jsUtils
	IScriptManager scriptManager
	IAliasManager aliasManager


	new() {
		consoleView = new ConsoleView()
		hostWindow = new UndecoratedUtilityWindow(new Scene(consoleView))

		val windowController = new ConsoleAppWindowController(hostWindow)
		windowController.setOpacity(0.85f)

		val consolePrompt = consoleView.consolePromptInput
		val consoleOutput = consoleView.consoleOutput
		val consoleProxy = new ConsoleProxy(consoleOutput, windowController)

		val errorStream = new PrintWriter(new OutputStream() {
			StringBuilder sb = new StringBuilder();

			override write(int c) throws IOException {
				if (c == '\n') {
					consoleOutput.addErrorEntry(sb.toString())
					sb = new StringBuilder()
				}
				else {
					sb.append(c as char)
				}
			}
		})

		database = new Database
		try {
			database.load(PathUtils.appSettingsDir + "/settings.db")
		}
		catch (RuntimeException exc) {
			consoleProxy.error(exc.message)
		}
		jsUtils = new JsUtilsProvider(errorStream)
		scriptManager = new JsScriptManager(jsUtils, database, consoleProxy)

		val aliasStorage = database.aliasesSection
		aliasManager = new AliasManager(aliasStorage)

		new CommandLineService(consolePrompt, consoleOutput, scriptManager, aliasManager)

		scriptManager.put("alias", new AliasScript(aliasManager, aliasStorage, jsUtils, consoleProxy))
		scriptManager.put("exec", new ExecScript(jsUtils))

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