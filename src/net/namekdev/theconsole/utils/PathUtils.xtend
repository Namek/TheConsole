package net.namekdev.theconsole.utils

import java.net.URI
import java.net.URISyntaxException
import java.nio.file.Path
import java.nio.file.Paths

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
}
