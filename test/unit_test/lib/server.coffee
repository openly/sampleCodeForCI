mockery = require 'mockery'

serverMock = mock ['listen']

fsMock = mock ['readdirSync', 'readFileSync', 'existsSync']

CTRL_PATH = __dirname + '/temp'
ctrlMock = mockClass 'setupRoutes'

confMock = mock 'get'

logMock = mock 'info'

pathMock = mock 'normalize'

messageMock = {
  CONFIG_NOT_SET: {
    HTTPS: 'Https config is not defined'
  }
}

enableMockery = ()->
  mockery.enable({ useCleanCache: true })
  mockery.warnOnUnregistered(false)

  mockery.registerMock 'fs', fsMock
  global.conf = confMock
  global.log = logMock
  global.message = messageMock
  mockery.registerMock CTRL_PATH + '/testcontroller', ctrlMock.constructorFn
  mockery.registerMock 'path', pathMock

disableMockery = ()->
  mockery.deregisterAll()
  mockery.disable()
  serverMock.reset()
  ctrlMock.reset()
  fsMock.reset()
  confMock.reset()
  logMock.reset()
  pathMock.reset()

errOnCreateServer = ()->
  Server = require '../../../src/lib/server'

  server = new Server
  errorFn = ()->
    server.createServer()

  errorFn.should.throw('createServer method is not implemented in sub class')

errOnHttpsConfNotSet = ()->
  Server = require '../../../src/lib/server'
  
  confMock.modify('get', returns: undefined)

  server = new Server

  errorFn = ()->
    server.getHttpsOptions()

  errorFn.should.throw('Https config is not defined')

errOnKeyCertFilesMissing = ()->
  Server = require '../../../src/lib/server'
  
  pathMock.modify 'normalize',
    returns: '/conf_dir/'

  confMock.modify 'get', returns: {
    key: 'path_to_key_file'
    certificate: 'path_to_cert_file'
  }

  fsMock.modify 'existsSync', returns: false

  server = new Server
  errorFn = ()->
    server.getHttpsOptions()

  errorFn.should.throw("Certificate file 'path_to_cert_file' or Key file 'path_to_key_file' provided for https connection are not found")

errOnHandleException = ()->
  Server = require '../../../src/lib/server'
  
  fsMock.modify 'existsSync', returns: true

  server = new Server
  errorFn = ()->
    server.handleException()

  errorFn.should.throw('handleException method is not implemented in sub class')

errOnRoutesSetupBefCreatingServer = ()->
  Server = require '../../../src/lib/server'
  
  fsMock.modify 'existsSync', returns: true

  server = new Server
  errorFn = ()->
    server.setupRoutes()

  errorFn.should.throw('Server is not created yet')

errOnRoutesSetupBefSetCtrlPath = ()->
  Server = require '../../../src/lib/server'
  server = new Server
  
  #assuming that createServer is called and it sets the server object
  server.server = serverMock

  errorFn = ()->
    server.setupRoutes()

  errorFn.should.throw('Controllers Directory path is not set')

setControllerPath = ()->
  Server = require '../../../src/lib/server'
  server = new Server

  #assuming that createServer is called and it sets the server object
  server.server = serverMock

  server.setControllerPath(CTRL_PATH)
  
  server.controllerPath.should.equal(CTRL_PATH).ok

setRoutesFromController = ()->
  Server = require '../../../src/lib/server'
  server = new Server
  
  server.server = serverMock

  fsMock.modify 'readdirSync', returns: ['testcontroller']
  
  server.setControllerPath(CTRL_PATH)
  server.setupRoutes()

  ctrlMock.isInstantiated().should.be.ok
  ctrlMock.isCalled('setupRoutes').should.be.ok

errOnListenBefCreateServer = ()->
  Server = require '../../../src/lib/server'
  server = new Server

  errorFn = ()->
    server.listen 3000, ->

  errorFn.should.throw('Server is not created yet')

listenToThePort = ()->
  Server = require '../../../src/lib/server'
  server = new Server

  server.server = serverMock

  serverMock.modify 'listen', takes:[3000, ->]

  server.listen 3000, -> 
    serverMock.isCalled('listen').should.be.ok

describe 'Server', ->
  beforeEach enableMockery
  afterEach disableMockery

  it 'Should throw error if createServer method is not defined in subclass', errOnCreateServer
  it 'Should throw error if handleException method is not defined in subclass', errOnHandleException
  it 'Should throw error if SetUpRoutes called before creating server', errOnRoutesSetupBefCreatingServer
  it 'Should throw error if SetUpRoutes called before setting Controllers Directory', errOnRoutesSetupBefSetCtrlPath
  it 'Should set controllers directory', setControllerPath
  it 'Should call setupRoutes method from each controller file', setRoutesFromController
  it 'should throw error if listen is called before creating server', errOnListenBefCreateServer
  it 'Should listen in the given port', listenToThePort