## The Console

### What?

JavaScript-able Console. Made on top of Java 8 and JavaFX.

Features:
* custom scripts to be called as commands
* command aliasing
* auto-reloading of scripts when script file is modified
* command invoke history like in bash (keys UP, DOWN)
* run one-line JavaScript code directly in shell (do some math or whatever)
* separated JSON configuration for every script
* tabs

## APIs

### Nashorn (Java 8 extension)

https://gist.github.com/WebReflection/9627010

https://docs.oracle.com/javase/8/docs/technotes/guides/scripting/nashorn/api.html


### Globals variables and functions

```js
args.length
args[0], args[1], ...
Utils.audioFilePlayer.play(filePath)
Utils.exec(filePath)
Utils.execAsync(filePath)
Utils.getClassName(object)
Utils.openUrl(encodeURI(someUrl))
Utils.requestUrl(url) //HTTP GET
console.log(text)
console.log(text, color)
console.error(text)
console.clear()
console.hide()
console.window
assert(bool, string)
assertInfo(bool, string)
JavaClass(className) // Java: Class.forName(className);
System // Java: System.class
```

Sources for globals:
* `Utils` is placed in [JsUtilsProvider.xtend](src/net/namekdev/theconsole/scripts/execution/JsUtilsProvider.xtend)
* `console` is [ConsoleProxy.xtend](src/net/namekdev/theconsole/scripts/ConsoleProxy.xtend)
* whole file script is lanched by [ConsoleContext.xtend#runJs()](src/net/namekdev/theconsole/state/ConsoleContext.xtend)
* Java->JavaScript bindings are made in [JavaScriptExecutor#ctor](src/net/namekdev/theconsole/scripts/execution/JavaScriptExecutor.xtend) 
[ConsoleContext.xtend#createJsEnvironment](src/net/namekdev/theconsole/state/ConsoleContext.xtend)

### Script Storage

Every script can store it's configuration or whatever. To see some examples go see `filesystem`.

1. Get your storage:
    ```js
    Storage = Storage.getGlobalStorage("myscript")
    ```

2. Get variable
    ```
    var path = Storage.get("path")
    console.log(path)
    ```

3. Overwrite variable and save Storage
    ```js
    var newPath = ...
    Storage.set("path", newPath)
    Storage.save()
    ```

### Assertion

You can `assert` whatever you like, e.g. script arguments.

When first argument of `assert`/`assertInfo` is not true, it stops whole scripts and displays given text to the console:

1. red text:
    ```js
    assert(args.length == 0, "Please, no args.")
    ```

2. white text:
    ```js
    assertInfo(args.length == 0, "Please, no args.")
    ```
