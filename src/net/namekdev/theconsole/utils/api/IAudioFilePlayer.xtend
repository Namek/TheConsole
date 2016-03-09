package net.namekdev.theconsole.utils.api

interface IAudioFilePlayer {
	def void playSync(String filePath)
	def void play(String filePath)
}