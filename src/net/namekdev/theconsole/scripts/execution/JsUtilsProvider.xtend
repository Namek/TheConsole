package net.namekdev.theconsole.scripts.execution

import java.awt.Desktop
import java.io.BufferedReader
import java.io.IOException
import java.io.InputStreamReader
import java.io.PrintWriter
import java.net.HttpURLConnection
import java.net.URI
import java.net.URL
import jdk.nashorn.internal.objects.NativeArray
import net.namekdev.theconsole.state.ConsoleContext
import net.namekdev.theconsole.utils.AudioFilePlayer
import net.namekdev.theconsole.utils.api.IAudioFilePlayer

class JsUtilsProvider {
//	private var PrintWriter errorStream

	public final IAudioFilePlayer audioFilePlayer = new AudioFilePlayer


	new(ConsoleContext consoleContext) {
		this.errorStream = consoleContext.errorStream
	}

	/**
	 * Joins strings by single space between and quoting args containing any space.
	 * @param arr array of strings
	 * @return joined quoted strings
	 */
	def public String argsToString(NativeArray arr) {
		val sb = new StringBuilder()

		val iter = arr.valueIterator()
		while (iter.hasNext()) {
			val arg = iter.next() as String

			if (arg.length() == 0 || arg.indexOf(' ') >= 0) {
				sb.append("\"")
				sb.append(arg)
				sb.append("\"")
			}
			else {
				sb.append(arg)
			}

			if (iter.hasNext()) {
				sb.append(' ')
			}
		}

		return sb.toString()
	}

	/**
	 * Joins strings by single space between and quoting args containing any space.
	 * @param arr array of strings
	 * @return
	 */
	def public String argsToString(String[] arr) {
		return argsToString(arr, 0)
	}

	/**
	 * Joins strings by single space between by quoting args containing any at least one space character.
	 * @param arr array of strings
	 * @return
	 */
	def public String argsToString(String[] arr, int beginIndex) {
		val sb = new StringBuilder()

		for (var i = beginIndex, val n = arr.length; i < n; i++) {
			val arg = arr.get(i)

			if (arg.length() == 0 || arg.indexOf(' ') >= 0) {
				sb.append("\"")
				sb.append(arg)
				sb.append("\"")
			}
			else {
				sb.append(arg)
			}

			if (i < n - 1) {
				sb.append(' ')
			}
		}

		return sb.toString()
	}

	def public String getClassName(Object obj) {
		return obj.getClass().getName()
	}

	def public String requestUrl(String url, String method) {
		if (url.indexOf(' ') >= 0) {
			errorStream.println("Utils.requestUrl() received url containing spaces. Use encodeURI() !")
			errorStream.flush()
			return null
		}

		try {
			val obj = new URL(url)
			val con = obj.openConnection() as HttpURLConnection
			con.setRequestMethod("GET")

			val response = con.getResponseCode()

			val in = new BufferedReader(new InputStreamReader(con.getInputStream()))
			val sb = new StringBuffer()

			var line = null as String
			while ((line = in.readLine()) != null) {
				sb.append(line)
			}
			in.close()

			return sb.toString()
		}
		catch (Exception exc) {
			exc.printStackTrace(errorStream)
			return null
		}
	}

	def public String requestUrl(String url) {
		return requestUrl(url, "GET")
	}

	def public void execAsync(String filepath) {
		val runtime = Runtime.getRuntime()

		try {
			runtime.exec(filepath)
		}
		catch (IOException e) {
			e.printStackTrace(errorStream)
		}
	}

	def public int exec(String filepath) {
		val runtime = Runtime.getRuntime()

		try {
			val process = runtime.exec(filepath)
			return process.waitFor()
		}
		catch (Exception e) {
			e.printStackTrace(errorStream)
			return -1
		}
	}

	def public void openUrl(String url) {
		if (url.indexOf(' ') >= 0) {
			errorStream.println("Utils.requestUrl() received url containing spaces. Use encodeURI() !")
			errorStream.flush()
			return
		}

		val desktop = Desktop.getDesktop()
        try {
            desktop.browse(new URI(url))
        }
        catch (Exception e) {
            e.printStackTrace(errorStream)
        }
	}

	def public void assertError(boolean condition, String error) {
		if (!condition) {
			throw new ScriptAssertError(error, true)
		}
	}

	def public void assertInfo(Boolean condition, String text) {
		if (!condition) {
			throw new ScriptAssertError(text, false)
		}
	}
}
