fs = require 'fs-extra'
Logger = require './index'
_ = require 'underscore'

class FileLogger extends Logger
  
  constructor: ()->
    @contents = []
    @writeStarted = false

  # 
  # ## configure
  # configure the directory path at which storage file needs be created
  # 
  # @param {object} opts, Configurable options {
  #   dir: 'some_dir',
  #   write_interval: 'some_time'(default: 60*1000[one minute]),
  #   file: 'some_file'(default: 'log.log')
  # }
  configure: (opts)->
    defaults = {
      write_interval: 60000 #one minute
      file: 'log.log'
    }
    _.extend(@, defaults, opts)

  # 
  # ## log
  #log the content to the file
  # 
  # @param {string} content
  log: (content)->
    throw new Error 'File Logger is not configured yet' unless @.dir?
    @contents.push content
    @_startWritingToFile() unless @writeStarted

  # 
  # ## _startWritingToFile
  #append the saved contents to the file on regular interval
  # 
  _startWritingToFile: ()->
    @writeStarted = true
    setInterval (
      ()=>
        if @contents.length > 0
          fs.appendFile "#{@.dir}/#{@.file}",
            "\n" + @contents.join("\n"),
            (e)=>
              throw e if e?
              @contents = []
    ), @.write_interval

module.exports = FileLogger