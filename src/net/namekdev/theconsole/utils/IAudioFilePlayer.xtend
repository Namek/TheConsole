package net.namekdev.theconsole.utils

interface IAudioFilePlayer {
	def void playSync(String filePath)
	def void play(String filePath)
}