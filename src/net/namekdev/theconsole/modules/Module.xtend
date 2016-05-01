package net.namekdev.theconsole.modules

import java.nio.file.Path

class Module {
	public val Path entryFile
	public val Path directory

	new(Path entryFile) {
		this.entryFile = entryFile
		this.directory = entryFile.parent
	}
}