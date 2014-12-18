fs = require 'fs'

class ITCServer
  constructor: () ->
    @server = null

  createServer:()->
    throw new Error "createServer method is not implemented in sub class"

  setControllerPath:(path) ->
    @controllerPath = path

  setupRoutes: () -> 
    throw new Error 'Server is not created yet' unless @server
    throw new Error 'Controllers Directory path is not set' unless @controllerPath

    fs.readdirSync(@controllerPath).forEach (file) =>
      ControllerClass = require @controllerPath + '/' + file
      contrObj = new ControllerClass()
      contrObj.setupRoutes(@server)

  handleException: ()->
    throw new Error "handleException method is not implemented in sub class"

  listen: (port, cb)->
    throw new Error 'Server is not created yet' unless @server
    log.info("App Started at port #{port}")
    @server.listen port, cb

module.exports = ITCServer