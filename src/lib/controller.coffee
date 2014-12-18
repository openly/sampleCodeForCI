class Controller
  constructor: () ->
  
  setupRoutes: (server)->
    throw new Error('Setup routes must be defined in the subclass')

module.exports = Controller