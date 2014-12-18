path = require("path")

filteredPathPrefix = path.resolve(__dirname, "..", "..")
originalPrepareStackTrace = undefined

if originalPrepareStackTrace = Error.prepareStackTrace
  Error.prepareStackTrace = (error, stack) ->
    originalString = originalPrepareStackTrace(error, stack)
    string = "Error: " + error.message + "\n"
    lines = originalString.replace("Error: " + error.message + "\n", "").replace(/\s*$/, "").split("\n")
    i = undefined
    i = 0
    while i < lines.length
      line = lines[i]
      callSite = stack[i]
      string = string + line + "\n"  if callSite.getFileName().indexOf(filteredPathPrefix) is 0
      i++
    return string