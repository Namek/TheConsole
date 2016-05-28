## The Console

### What?

JavaScript-able shell. Made on top of Java 8 and JavaFX.

![The Console](https://namek.github.io/TheConsole/screenshots/ss1.png)

### Features:

* custom scripts to be called as commands
* command aliasing
* **auto-reloading** of scripts when script file is modified
* command **invocation history** like in bash (keys UP, DOWN)
* run JavaScript one-liners *directly in shell* (do some math or whatever)
* separated JSON configuration for every script
* multiple **tabs** having separated JavaScript environments

### More features:
* modules in style of NodeJS
* scriptable argument/input/path completion
* scriptable [REPLs](https://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop), e.g. bash, zsh or whatever else can be connected through JavaScript

### Links

* [blogposts on NamekDev about development of this project](www.namekdev.net/topics/dailies/the-console/)
* [Trello - project planning](https://trello.com/b/4Ez5pAx7/the-console-2)
* [The Console - Proof of Concept](https://github.com/Namek/TheConsole_POC)
* [Scripting Documentation](https://github.com/Namek/TheConsole/wiki)

## Getting started

1. Latest released build can be found on [releases page](https://github.com/Namek/TheConsole/releases/).

2. To toggle visibility of The Console hit ``CTRL + ` ``.

3. The Console by itself can't do much besides running JavaScript. Just go into `%APPDATA/TheConsole/scripts` (create if doesn't exists) and create some `.js` files. Every single `.js` file (which doesn't belong to some module) is a command name, i.e. `currency.js` can be called using `currency` command.


## Installation (for Windows)

The Console doesn't need any real installation but you may find it useful to autostart the app with operating system.

To do so, simply download released (or built) `theconsole-{version}.jar` file and put it anywhere you like. Next, create a shortcut to this file, then move it into
`%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup`.


## Build from sources

Launch `mvn package` to get `target/theconsole-{version}.jar`.


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
