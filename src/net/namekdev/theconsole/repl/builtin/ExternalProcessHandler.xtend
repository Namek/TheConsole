package net.namekdev.theconsole.repl.builtin

import net.namekdev.theconsole.commands.api.ICommandLineHandler
import net.namekdev.theconsole.commands.api.ICommandLineUtils
import net.namekdev.theconsole.state.api.IConsoleContext
import net.namekdev.theconsole.utils.PathUtils
import java.io.InputStreamReader
import java.io.BufferedReader

abstract class ExternalProcessHandler implements ICommandLineHandler {
	var ProcessBuilder pb
	var Process process
	var Thread inputThread

	volatile var keepAlive = true

	def abstract String determineProcessPath()

	override init(IConsoleContext context, ICommandLineUtils utils) {
		pb = new ProcessBuilder(determineProcessPath())
		pb.directory(PathUtils.scriptsDir.toFile)
		pb.redirectErrorStream(true)

		process = pb.start()

		inputThread = new Thread([
			val input = new BufferedReader(new InputStreamReader(process.inputStream, "UTF-8"))

			while (keepAlive) {
				if (!process.alive) {
					context.output.addErrorEntry("bash process is dead.")
					return
				}

				while (input.ready) {
					context.output.addTextEntry(input.readLine())
				}

				Thread.sleep(50)
			}
		])
		inputThread.start()
	}

	override dispose() {
		try {
			keepAlive = false
		}
		catch (Exception exc) { }
		finally {
			inputThread = null
		}
	}

	override handleCompletion() {
	}

	override handleExecution(String input, ICommandLineUtils utils, IConsoleContext context) {
		context.output.addInputEntry(input)
		process.outputStream.write(input.bytes)
		process.outputStream.write(10) // ENTER
		process.outputStream.flush()
		

		return true
	}
}