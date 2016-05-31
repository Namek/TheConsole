package net.namekdev.theconsole.repl.builtin

class CygwinBashHandler extends ExternalProcessHandler {

	override determineProcessPath() {
		"N:/.babun/cygwin/bin/bash.exe"
	}

	override getName() {
		'cygwin_bash'
	}
}