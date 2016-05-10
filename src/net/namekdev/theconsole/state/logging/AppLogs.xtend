package net.namekdev.theconsole.state.logging

import rx.Observable
import java.util.ArrayList

class AppLogs {
	val logs = new ArrayList<AppLog>
	public val observable = Observable.from(logs)

	def void log(String text, boolean isError) {
		logs.add(new AppLog(text, isError))
	}

	def void log(String text) {
		log(text, false)
	}

	def void error(String text) {
		log(text, true)
	}
}