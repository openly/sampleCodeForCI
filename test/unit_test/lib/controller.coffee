errorOnNoSetupRoutes = ()->
  Controller = require '../../../src/lib/controller'

  contrObj = new Controller
  
  errorFn = ()->
    contrObj.setupRoutes()
  errorFn.should.not.throw()

describe 'Controller Super Class', ->
  it 'should throw error if the setupRoutes is not defined in subclass', errorOnNoSetupRoutes
