package net.namekdev.theconsole.utils

import org.junit.Test
import static extension org.junit.Assert.*

class PathUtilsTest {
	@Test
	def completePathTest() {
		PathUtils.normalize('''C:/Windows\Fonts''')
			.assertEquals('C:/Windows/Fonts')
	}
}