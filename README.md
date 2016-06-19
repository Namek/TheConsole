## The Console

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

* [blogposts on NamekDev about development of this project](https://www.namekdev.net/topics/dailies/the-console/)
* [Trello - project planning](https://trello.com/b/4Ez5pAx7/the-console-2)
* [The Console - Proof of Concept](https://github.com/Namek/TheConsole_POC)
* [Scripting Documentation / Wiki](https://github.com/Namek/TheConsole/wiki)
* [Slides for presentation at Daj Się Poznać 2016 in Microsoft](http://namekdev.net/presentations/TheConsole_DajSiePoznac2016/)

## Getting started

1. Latest released build can be found on [releases page](https://github.com/Namek/TheConsole/releases/).

2. To toggle visibility of The Console hit ``CTRL + ` ``.

3. The Console by itself can't do much besides running JavaScript. Just go into `%APPDATA/TheConsole/scripts` (create if doesn't exists) and create some `.js` files. Every single `.js` file (which doesn't belong to some module) is a command name, i.e. `currency.js` can be called using `currency` command.

## Build from sources

Launch `mvn clean package -Dmaven.test.skip=true` to get `target/theconsole-{version}.jar`.


## APIs and help

Check out the [Wiki](../../wiki)!
