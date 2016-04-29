package net.namekdev.theconsole.state

import net.namekdev.theconsole.state.api.IConsoleContext
import java.util.function.Consumer
import java.util.concurrent.BlockingQueue
import java.util.concurrent.LinkedBlockingQueue

class ContextTaskManager {
	public static val MODULE_LOAD = 1
	public static val MODULE_UNLOAD = 3

	val BlockingQueue<ContextTask> newContextTasks = new LinkedBlockingQueue


	/**
	 * Makes sure to remove unload tasks for same module.
	 */
	def addModuleLoading(String entryFile, Consumer<IConsoleContext> consumer) {
		newContextTasks.removeIf([type == MODULE_UNLOAD && value.equals(entryFile)])

		if (!newContextTasks.exists[type == MODULE_LOAD && value.equals(entryFile)]) {
			newContextTasks.add(new ContextTask(MODULE_LOAD, consumer, entryFile))
		}
	}

	def executeTasksOnNewContext(IConsoleContext newContext) {
		newContextTasks.forEach[
			consumer.accept(newContext)
		]
	}

	static class ContextTask {
		public val int type
		public val Consumer<IConsoleContext> consumer
		public var String value

		new(int type, Consumer<IConsoleContext> consumer) {
			this.type = type
			this.consumer = consumer
		}

		new(int type, Consumer<IConsoleContext> consumer, String value) {
			this(type, consumer)
			this.value = value
		}
	}
}