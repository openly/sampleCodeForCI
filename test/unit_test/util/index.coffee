moment = require 'moment'

obsCredentials = ()->
  params = {
    field1: 'value1'
    field2: 'value2'
    field3: 'value3'
    field4: 'value4'
  }
  obscFields = ['field2', 'field3']
  obscParams = {
    field1: 'value1'
    field2: '********'
    field3: '********'
    field4: 'value4'
  }

  Util = require '../../../src/util'
  results = Util.obscureCredentials params, obscFields

  results.should.eql(obscParams)

cloneJSONObj = ()->
  Util = require '../../../src/util'

  originalObject = {
    'array': ['value1', 'value2']
    'object': {
      'nested_array': ['value3', 'value4']
    }
    'string': 'value5'
  }

  clonedObject = Util.clone(originalObject)
  clonedObject.should.eql(originalObject)

  originalObject['array'] = ['another_value']
  clonedObject.should.not.eql(originalObject)

  originalObject['object']['nested_array'] = ['another_value2']
  clonedObject.should.not.eql(originalObject)  

getNoDaysSince = ()->
  Util = require '../../../src/util'

  date = moment().format('YYYY-MM-DD HH:mm:ss')
  result = Util.getNoDaysSince date
  result.should.eql('0 Days')

  date = moment().subtract(1, 'day')
  result = Util.getNoDaysSince date
  result.should.eql('1 Day')

  date = moment().subtract(3, 'day')
  result = Util.getNoDaysSince date
  result.should.eql('3 Days')

getFirstNWords = ()->
  Util = require '../../../src/util'

  str = 'First Second Third'
  result = Util.getFirstNWords str, 4
  result.should.eql(str)

  str = 'First Second Third Fourth'
  result = Util.getFirstNWords str, 4
  result.should.eql(str)

  str = 'First Second Third Fourth Fifth'
  result = Util.getFirstNWords str, 4
  result.should.eql('First Second Third Fourth...')

getFirstNChars = ()->
  Util = require '../../../src/util'

  str = '123'
  result = Util.getFirstNChars str, 4
  result.should.eql(str)

  str = '1234'
  result = Util.getFirstNChars str, 4
  result.should.eql(str)

  str = '123 45'
  result = Util.getFirstNChars str, 4
  result.should.eql('1...')

describe 'Utility Functions', ->
  it 'should obscure the credentials', obsCredentials
  it 'should clone the JSON object', cloneJSONObj
  it 'should get the number of days since', getNoDaysSince
  it 'should get first N words in a string', getFirstNWords
  it 'should get first N chars in a string', getFirstNChars