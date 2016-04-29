package net.namekdev.theconsole.scripts.execution

import javax.script.Bindings
import javax.script.ScriptEngineManager
import java.util.function.Function
import javax.script.ScriptContext
import javax.script.Invocable
import javax.script.ScriptEngine
import javax.script.ScriptException
import com.google.common.base.Charsets
import com.google.common.io.Resources
import net.namekdev.theconsole.utils.PathUtils
import java.nio.file.Path

/**
 * Describes JavaScript environment that consists of useful bindings specific to The Software.
 */
class JavaScriptExecutor {
	val ScriptEngineManager engineManager
	var ScriptEngine engine
	var Invocable invocable
	var Bindings engineBindings

	val SCRIPTS_DIR = PathUtils.scriptsDir
	val SCRIPTS_DIR_STR = SCRIPTS_DIR.toString().replace('\\', '/')


	new() {
		engineManager = new ScriptEngineManager()
		engine = engineManager.getEngineByName("nashorn")
		invocable = engine as Invocable
		engineBindings = engine.getBindings(ScriptContext.ENGINE_SCOPE)

		bindObject("JavaClass", new Function<String, Class<?>>() {
			override apply(String className) {
				try {
					return Class.forName(className)
				}
				catch (Exception exc) {
					throw new RuntimeException(exc)
				}
			}
		})

		bindClass("System", typeof(System))

		eval(Resources.toString(this.class.getResource("require.js"), Charsets.UTF_8) + '.localDir = "' + SCRIPTS_DIR_STR + '"')
	}

	def void bindClass(String variableName, Class<?> cls) {
		bindClass(variableName, cls.getName())
	}

	def void bindClass(String variableName, String classPath) {
		try {
			engine.eval("var " + variableName + " = JavaClass('" + classPath + "').static")
		}
		catch (ScriptException e) { }
	}

	def void bindObject(String variableName, Object obj) {
		try {
			engineBindings.put(variableName, obj)
		}
		catch (Exception exc) { }
	}

	def Object eval(String scriptCode) {
		return eval(scriptCode, true)
	}

	def Object eval(String scriptCode, boolean returnExceptionObject) {
		var ret = null as Object

		try {
			ret = engine.eval(scriptCode, engineBindings)
		}
		catch (Exception e) {
			if (returnExceptionObject) {
				ret = e
			}

			if (!(e instanceof ScriptException)) {
				e.printStackTrace()
			}
		}

		return ret
	}

	/**
	 * Load module be <code>require()</code>-ing given <code>.js</code> file.
	 */
	def void loadModule(Path entryFile) {
		val path = PathUtils.normalize(SCRIPTS_DIR.relativize(entryFile))
		val pathParts = path.split('/')
		val name = pathParts.get(pathParts.length-2)

		// if same module is already loaded then unload it first
		val module = engine.get(name)
		if (module != null) {
			eval('''
				if («name».onunload)
					«name».onunload();
			''')
		}

		// load module and leave it as a global variable «name»
		eval('''
			console.log("Loading module: «name»");
			var «name» = require("«path»");

			if («name».onload)
				«name».onload();
		''')

	}
}
