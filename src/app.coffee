async = require 'async'

loadConfigurations = (cb)->
  global.conf = require 'config'
  cb()

loadLoggers = (cb)->
  log = require './lib/log'

  FileLogger = require './lib/loggers/file'
  fileLogger = new FileLogger
  fileLogger.configure({
    dir: __dirname + '/../logs'
    file: 'sample.log'
    write_interval: 1000
  })

  log.addLogger(fileLogger)
  global.log = log
  cb()

tasks = [loadConfigurations, loadLoggers]
async.series tasks, (e)->
  throw e if e?

  require './web_app/app.coffee'