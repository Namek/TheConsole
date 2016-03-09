package net.namekdev.theconsole.utils

import java.io.File
import java.io.IOException
import java.util.concurrent.Executors
import javax.sound.sampled.AudioFormat
import javax.sound.sampled.AudioInputStream
import javax.sound.sampled.AudioSystem
import javax.sound.sampled.DataLine.Info
import javax.sound.sampled.SourceDataLine
import net.namekdev.theconsole.utils.api.IAudioFilePlayer

import static javax.sound.sampled.AudioFormat.Encoding.PCM_SIGNED
import static javax.sound.sampled.AudioSystem.getAudioInputStream

/**
 * Usage: <pre><code>
 * val IAudioFilePlayer player = new AudioFilePlayer()
 * player.play("something.mp3")
 * player.play("something.ogg")
 * </code>
 * </pre>
 */
class AudioFilePlayer implements IAudioFilePlayer {
	val buffer = newByteArrayOfSize(65536)
	val executor = Executors.newSingleThreadExecutor()


	override playSync(String filePath) {
		val file = new File(filePath)

		if (!file.exists) {
			return false
		}

		return playSync(file)
	}

	override play(String filePath) {
		val file = new File(filePath)

		if (!file.exists) {
			return false
		}

		executor.execute([
			playSync(filePath)
		])

		return true
	}

	def private playSync(File file) {
		var success = true

		var AudioInputStream in
		try {
			in = getAudioInputStream(file)
			val outFormat = getOutFormat(in.getFormat())
			val info = new Info(typeof(SourceDataLine), outFormat)

			var SourceDataLine line
			try {
				line = AudioSystem.getLine(info) as SourceDataLine

				if (line != null) {
					line.open(outFormat)
					line.start()
					stream(getAudioInputStream(outFormat, in), line)
					line.drain()
					line.stop()
				}

			}
			catch (Exception e) {
				if (line != null) {
					line.close()
				}
				success = false
			}
		}
		catch (Exception e) {
			success = false
		}
		finally {
			if (in != null) {
				in.close()
			}
		}

		return success;
	}

	def private AudioFormat getOutFormat(AudioFormat inFormat) {
		val int ch = inFormat.getChannels()
		val float rate = inFormat.getSampleRate()
		return new AudioFormat(PCM_SIGNED, rate, 16, ch, ch * 2, rate, false)
	}

	def private void stream(AudioInputStream in, SourceDataLine line) throws IOException {
		for (var n = 0; n != -1; n = in.read(buffer, 0, buffer.length)) {
			line.write(buffer, 0, n)
		}
	}
}