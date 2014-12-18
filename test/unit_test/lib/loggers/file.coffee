mkry = require 'mockery'

fsMock = mock 'appendFile'

enableMockery = ()->
  mkry.enable warnOnUnregistered: false, warnOnReplace: false
  mkry.registerMock 'fs-extra', fsMock

disableMockery = ()->
  mkry.deregisterAll()
  mkry.disable()
  fsMock.reset()

sleep = (s)->
  e = new Date().getTime() + (s*60)
  null while (new Date().getTime() <= e)

errBefConf = ()->
  FileLogger = require '../../../../src/lib/loggers/file'

  fileLogger = new FileLogger

  errFn = ()->
    fileLogger.log('Msg')

  errFn.should.throw('File Logger is not configured yet')

configureFileLogger = ()->
  FileLogger = require '../../../../src/lib/loggers/file'

  fileLogger = new FileLogger

  fileLogger.configure({
    dir:'some_dir'
    write_interval: 'some_time'
    file: 'some_file'
  })

  fileLogger.dir.should.eql('some_dir')
  fileLogger.write_interval.should.eql('some_time')
  fileLogger.file.should.eql('some_file')

appendLogFrRegInterval = ()->
  FileLogger = require '../../../../src/lib/loggers/file'

  content = "\nfirst_content\nsecond_content"
  
  fsMock.modify 'appendFile',
    takes: (args)->
      return args[0] is 'some_dir/some_file' and
        args[1] is content
    calls: 2
    with: [null]

  fileLogger = new FileLogger

  fileLogger.configure({
    dir:'some_dir'
    write_interval: 1
    file: 'some_file'
  })

  fileLogger.log('first_content')
  fileLogger.log('second_content')
  fileLogger.writeStarted.should.eql(true)
  sleep(5)

describe 'File Logger', ->
  beforeEach enableMockery
  afterEach disableMockery

  it 'should throw error if logged before configuration', errBefConf
  it 'should configure the file logger', configureFileLogger
  it 'should write the files for regular intervals', appendLogFrRegInterval