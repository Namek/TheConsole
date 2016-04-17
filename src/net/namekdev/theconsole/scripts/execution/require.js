// provides require() function for module loading

(function (context) {'use strict';

  if ('require' in context) return

  var settings = Object.create(null)
  var cache = Object.create(null)

  function executeAndCache(file) {
    var exports = {}, module = {exports: exports, id: file}

    Function('require', 'exports', 'module', read(file))
      .call(exports, require, exports, module)

    cache[file] = module.exports
    return cache[file]
  }

  function read(filePath) {
    if (settings.localDir)
      filePath = settings.localDir + '/' + filePath

    return new java.lang.String(
      java.nio.file.Files.readAllBytes(java.nio.file.Paths.get(filePath))
    )
  }

  context.require = require

  function require(file) {
    if (file.slice(-3) !== '.js') file += '.js'
    return cache[file] || executeAndCache(file)
  }

  return settings
}(this))
