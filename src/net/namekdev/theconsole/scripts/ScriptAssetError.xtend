package net.namekdev.theconsole.scripts

class ScriptAssertError extends Error {
	public val String text
	public val boolean isError

	new(String text, boolean isError) {
		this.text = text
		this.isError = isError
	}
}
