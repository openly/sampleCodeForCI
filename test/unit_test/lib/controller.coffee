errorOnNoSetupRoutes = ()->
  Controller = require '../../../src/lib/controller'

  contrObj = new Controller
  
  errorFn = ()->
    contrObj.setupRoutes()
  errorFn.should.throw()

describe 'Controller Super Class', ->
  it 'should throw error if the setupRoutes is not defined in subclass', errorOnNoSetupRoutes
