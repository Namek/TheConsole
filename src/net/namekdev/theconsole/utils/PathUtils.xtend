package net.namekdev.theconsole.utils

import java.net.URI
import java.net.URISyntaxException
import java.nio.file.Path
import java.nio.file.Paths
import java.util.ArrayList
import java.io.File
import java.util.stream.Collectors
import java.util.regex.Pattern

public abstract class PathUtils {
	public static final Path appSettingsDir = Paths.get(System.getenv("AppData"), "TheConsole")
	public static final Path scriptsDir = appSettingsDir.resolve("scripts")

	public static final Path workingDir = try {
		val myURL = typeof(PathUtils).getProtectionDomain().getCodeSource().getLocation()
		var myURI = null as URI

		try {
		    myURI = myURL.toURI();
		}
		catch (URISyntaxException exc) { }

		return Paths.get(myURI)
	} catch (Exception exc) { throw exc }

	def static String normalize(String path) {
		return path.replace('\\', '/').replace('//', '/')
	}

	def static String normalize(Path path) {
		return normalize(path.toString)
	}

	/**
	 * When given path exists then:
	 * <ol>
	 *  <li>if letter-case is improper then fixed case is returned
	 *  <li>if letter-case is same then path with added slash on the end is returned
	 *  <li>if it already contains slash on the end then folder contents list is returned
	 * </ol>
	 *
	 * Otherwise, it tries to suggest completion list based on parent path contents,
	 * e.g. for {@code C:/Window} it will yield {@code C:/Windows}.
	 *
	 * @todo support unix-like systems which are not case-insensitive
	 */
	def static String[] tryCompletePath(String absolutePath) {
		val suggestions = new ArrayList<String>

		// first, try to complete what's given
		val givenFile = new File(absolutePath)
		val givenPathExists = givenFile.exists
		if (givenPathExists) {
			val path = normalize(givenFile.absolutePath)
			val givenPathEndsWithSlash = absolutePath.charAt(absolutePath.length - 1).equals("/".charAt(0))

			// check for letter case
			if (!path.equals(absolutePath) && !(path+'/').equals(absolutePath)) {
				suggestions.add(path)
				return suggestions
			}
			else if (!givenPathEndsWithSlash) {
				suggestions.add(path + '/')
				return suggestions
			}
		}

		// now try to cut out a segment placed after latest path delimiter ('/' or '\')
		val segments = absolutePath.split('''[/\\]''')
		val folderPath = segments.stream
			.limit(if (givenPathExists) segments.size else segments.size - 1)
			.collect(Collectors.joining('/'))

		val file = new File(folderPath)
		if (file.isDirectory) {
			var contents = file.list

			if (!givenPathExists) {
				val completionSegment = segments.last

				// list all matching contents of directory
				val caseInsensitiveStartsWith = Pattern.compile(
					'^' + completionSegment,
					Pattern.UNICODE_CHARACTER_CLASS.bitwiseOr(Pattern.CASE_INSENSITIVE)
				)

				contents = contents
					.filter[path |
						val npath = normalize(folderPath + '/' + path)
						val fileName = npath.substring(npath.lastIndexOf('/')+1)
						caseInsensitiveStartsWith.matcher(fileName).find
					]
			}

			suggestions.addAll(contents.map[path | new File(file, path).absolutePath])
		}

		return suggestions.stream.distinct.collect(Collectors.toList)
	}

	/**
	 * Removes path relativeness (e.g. {@code 'cd/../cd'} is replaced to {@code cd}).
	 */
	def static String toCanonicalPath(File file) {
		return Paths.get(file.canonicalPath).normalize.toString
	}

	/**
	 * Removes path relativeness (e.g. {@code 'cd/../cd'} is replaced to {@code cd}).
	 */
	def static String toCanonicalPath(String path) {
		return toCanonicalPath(new File(path))
	}
}
