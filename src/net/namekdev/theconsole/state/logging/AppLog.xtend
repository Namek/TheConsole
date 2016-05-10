package net.namekdev.theconsole.state.logging

class AppLog {
	public val String text
	public val boolean isError

	new(String text, boolean isError) {
		this.text = text
		this.isError = isError
	}

	new(String text) {
		this.text = text
		this.isError = false
	}
}