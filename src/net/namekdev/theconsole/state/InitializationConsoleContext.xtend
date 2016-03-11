package net.namekdev.theconsole.state

import java.util.ArrayList
import net.namekdev.theconsole.scripts.ConsoleProxy
import net.namekdev.theconsole.state.InitializationConsoleContext.Entry
import net.namekdev.theconsole.state.api.IConsoleContext
import net.namekdev.theconsole.view.api.IConsoleOutput

/**
 * This is a temporary {@link IConsoleContext} which keeps
 * initialization log entries until whole UI and state is initialized.
 */
class InitializationConsoleContext implements IConsoleContext {
	public val entries = new ArrayList<Entry>

	private static val CommonInitError = "I'm during initialization"


	override getInput() {
		return null
	}

	override getOutput() {
		return deferredOutput
	}

	override getProxy() {
		return deferredOutputProxy
	}

	override getErrorStream() {
		throw new UnsupportedOperationException(CommonInitError)
	}

	override getJsUtils() {
		throw new UnsupportedOperationException(CommonInitError)
	}

	override getJsEnv() {
		throw new UnsupportedOperationException(CommonInitError)
	}

	override runJs(String code, Object[] args, Object context) {
		throw new UnsupportedOperationException(CommonInitError)
	}

	override runUnscopedJs(String code) {
		throw new UnsupportedOperationException(CommonInitError)
	}


	val deferredOutput = new IConsoleOutput {
		override addTextEntry(String text) {
			entries.add(new Entry(text, false))
			return null
		}

		override addErrorEntry(String text) {
			entries.add(new Entry(text, true))
			return null
		}

		override addInputEntry(String text) {
			throw new UnsupportedOperationException("input entry on init doesn't make sense!")
		}

		override addTextEntry(String text, int colorHex) {
			throw new UnsupportedOperationException("color doesn't make sense!")
		}

		override clear() {
			throw new RuntimeException("console.clear() is not expected to be called during app initialization")
		}
	}

	val deferredOutputProxy = new ConsoleProxy(deferredOutput, null)


	public static class Entry {
		public val String text
		public val boolean isError

		new(String text, boolean isError) {
			this.text = text
			this.isError = isError
		}
	}

}