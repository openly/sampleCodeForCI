Server = require '../lib/server'
express = require 'express'
session = require 'express-session'
Controller = require './controller'
helmet = require 'helmet'

class WebAppServer extends Server

  createServer: ()->
    @server = express()

    @server.use('/static', express.static(__dirname + '/../../static'))

    @server.engine 'mustache', require 'mustache-express4'
    @server.set 'view engine', 'mustache'
    @server.set 'views', __dirname + '/views/'
    @server.set 'partials', __dirname + '/views/partials'
        
    #To handle exceptions
    @server.use(require('express-domain-middleware'))

    @server.use(helmet())
    #to trust the reverse proxy
    @server.set('trust proxy', 1)

  listen: (port, cb)->
    throw new Error 'Server is not created yet' unless @server?
    
    log.info("Web App Started at port #{port}")
    @server.listen port, cb

  handleException: ()->
    throw new Error 'Server is not created yet' unless @server?
    
    controller = new Controller()

    @server.use (err, req, res, next)->
      return next() unless err?

      renderValues = { message: err.message }
      renderValues = controller.mergeDefRenderValues(renderValues)
      res.render('500', renderValues)

      #To DO: restart the application, as it catches uncaught exceptions also

  #We can set the application level variables here
  setDefAppLevelVars: ()->
    throw new Error 'Server is not created yet' unless @server
    
    @server.use (req, res, next)->
      global.defaultAppVars = {}
      next()

module.exports = WebAppServer