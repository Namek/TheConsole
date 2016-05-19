package net.namekdev.theconsole.utils

import java.io.File
import java.util.List
import org.junit.Test
import org.junit.runner.RunWith
import org.powermock.core.classloader.annotations.PrepareForTest
import org.powermock.core.classloader.annotations.SuppressStaticInitializationFor
import org.powermock.modules.junit4.PowerMockRunner

import static org.powermock.api.mockito.PowerMockito.*

import static extension org.junit.Assert.*

@RunWith(PowerMockRunner)
@PrepareForTest(PathUtils)
@SuppressStaticInitializationFor("net.namekdev.theconsole.utils.PathUtils")
class PathUtilsTest {
	@Test
	def void normalize() {
		PathUtils.normalize('''C:/Windows\Fonts''')
			.assertEquals('C:/Windows/Fonts')
	}

	@Test
	def void completePathToOneOption() {
		val inputPath = 'c:/window'
		val expectedCompletion = 'c:/Windows'

		// mock: given path doesn't exist on disk
		mockNewFileWithExistance(inputPath, false)

		// mock: list contents of 'C:/'
		val mockFileDirC = mockNewFileAsDirectoryWithContents('c:', #[
			'Windows', 'Program Files', 'Users'
		])

		// mock: return canonical path (with big 'C')
		mockNewFileWithAbsolutePath(mockFileDirC, 'c:', 'Windows', expectedCompletion)

		val suggestions = PathUtils.tryCompletePath(inputPath)
		assertEquals(1, suggestions.size)
		expectedCompletion.assertEquals(suggestions.get(0))
	}

	@Test
	def void completePathToCorrectLetterCase() {
		val inputPath = 'c:'
		val expectedPath = 'c:/'
		val canonicalPath = 'c:\\'

		val mockDirC = mockNewFileWithExistance(inputPath, true)
		when(mockDirC.absolutePath).thenReturn(canonicalPath)

		val suggestions = PathUtils.tryCompletePath(inputPath)

		assertEquals(1, suggestions.size)
		expectedPath.assertEquals(suggestions.get(0))
	}

	@Test
	def void completePathToEndWithSlash() {
		val inputPath = 'C:/Windows'

		val mockFile = mockNewFileWithExistance(inputPath, true)
		when(mockFile.absolutePath).thenReturn('C:/Windows')

		val suggestions = PathUtils.tryCompletePath(inputPath)

		assertEquals(1, suggestions.size)
		suggestions.get(0).assertEquals('C:/Windows/')
	}

	/**
	 * Input path of existing folder contains slash on the end
	 * so folder contents list is expected.
	 */
	@Test
	def void completePathToListContents() {
		val inputPath = 'c:/'
		val folderContents = #['Windows', 'Program Files', 'Users']

		// mock: path exists
		val mockFileDirC_1 = mockNewFileWithExistance(inputPath, true)
		when(mockFileDirC_1.absolutePath).thenReturn('c:')

		// mock: list contents of 'C:/'
		val mockFileDirC_2 = mockNewFileAsDirectoryWithContents('c:', folderContents)

		// mock: for every child return a canonical path (with big 'C')
		folderContents.forEach[child |
			mockNewFileWithAbsolutePath(mockFileDirC_2, 'c:', child, inputPath + child)
		]

		val suggestions = PathUtils.tryCompletePath(inputPath)

		folderContents.size.assertEquals(suggestions.size)
		folderContents.forEach[child |
			val expectedPath = inputPath + child
			assertTrue(suggestions.contains(expectedPath))
		]
	}

	@Test
	def void completePathWithSpace() {
		val inputParentPath = 'c:/users'
		val inputPath = inputParentPath + '/all'
		val expectedCompletion = 'C:/Users/All Users'
		val usersDirContents = #['All Users', 'Something else that does not match']

		// mock: 'c:/users/all' doesn't exist
		mockNewFileWithExistance(inputPath, false)

		// mock: list contents of 'c:/users'
		val mockUsersDir = mockNewFileAsDirectoryWithContents(inputParentPath, usersDirContents)

		// mock: canonical path of expected completion
		mockNewFileWithAbsolutePath(mockUsersDir, inputParentPath, 'All Users', expectedCompletion)

		val suggestions = PathUtils.tryCompletePath(inputPath)

		1.assertEquals(suggestions.size)
		expectedCompletion.assertEquals(suggestions.get(0))
	}


	def mockNewFileWithExistance(String inputPath, boolean fileExists) {
		val mockFile = mock(File)
		whenNew(File).withArguments(inputPath).thenReturn(mockFile)
		when(mockFile.exists).thenReturn(fileExists)

		return mockFile
	}

	def mockNewFileAsDirectoryWithContents(String parentPath, List<String> strings) {
		val mockFile = mock(File)
		whenNew(File).withArguments(parentPath).thenReturn(mockFile)
		when(mockFile.isDirectory).thenReturn(true)
		when(mockFile.list).thenReturn(strings)

		return mockFile
	}

	def File mockNewFileWithAbsolutePath(File parentFile, String parentPath, String contentName, String retAbsolutePath) {
		val mockFile = mock(File)
		whenNew(File).withArguments(parentFile, contentName).thenReturn(mockFile)
		when(mockFile.absolutePath).thenReturn(retAbsolutePath)

		return mockFile
	}
}