errOnNoLogMethod = ()->
  Logger = require '../../../../src/lib/loggers'

  logger = new Logger

  errFn = ()->
    logger.log('some_message')
  errFn.should.throw('Log method is not defined')

describe 'Logger Super Class', ->
  it 'should throw error if log method is not defined', errOnNoLogMethod