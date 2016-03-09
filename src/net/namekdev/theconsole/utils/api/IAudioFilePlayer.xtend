package net.namekdev.theconsole.utils.api

interface IAudioFilePlayer {
	def boolean playSync(String filePath)
	def boolean play(String filePath)
}