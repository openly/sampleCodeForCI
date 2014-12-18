mkry = require 'mockery'

mongoClientMock = mock 'connect'
dbMock = mock [
  'collection', 'toArray'
  'find', 'findOne',
  'save', 'update', 'remove', 'count'
  'sort', 'skip', 'limit', 'aggregate'
  ,'once'
]
objectIDClassMock = mockClass 'isValid'
objectIDMock = objectIDClassMock.constructorFn
objectIDMock['isValid'] = (str)->
  return true

enableMockery = ()->
  mkry.enable warnOnUnregistered: false, warnOnReplace: false, useCleanCache: true
  mkry.registerMock 'mongodb', {
    MongoClient: mongoClientMock
    ObjectID: objectIDMock
  }
  
disableMockery = ()->
  mkry.deregisterAll()
  mkry.disable()
  mongoClientMock.reset()
  dbMock.reset()
  objectIDClassMock.reset()
  global.mongoDBConn = null

dbConnArgs = {
  user: 'some_user'
  password: 'some_pass'
  server: 'some_server'
  database: 'some_db'
  port: 'some_port'
}
schema = {
  fields: {
    'field1': 'fieldType1'
    'field2': 'fieldType2'
  }
  table: 'some_table'
}
fields = ['field1', 'field2']
filters = {'field1': 'value1'}
options = {
  'sort': {'some_fields': 'ASC'}
  'limit': {
    'offset': 'idx' 
    'count': 'noRec'
  }
}
sampleRecords = [
  {'_id': 'IdObject1', 'field1': 'value1', 'field2': 'value2'},
  {'_id': 'IdObject2', 'field1': 'value3', 'field2': 'value4'}
]
sampleRecord = sampleRecords[0]
params = {'field1': 'value1', 'field2': 'value2'}

errOnNoISDBConfig = ()->
  ISAdapter = require '../../../../src/lib/adapters/internal_storage'

  internalAd = new ISAdapter()
  errFn = ()->
    internalAd.getConnection(->)
  errFn.should.throw('Internal Storage DB is not configured yet')

connectToInternalStorage = ()->
  ISAdapter = require '../../../../src/lib/adapters/internal_storage'

  mongoClientMock.modify 'connect',
    takes: [
      'mongodb://some_user:some_pass@some_server:some_port/some_db'
      ->
    ]
    calls: 1,
    with: [null, dbMock]

  internalAd = new ISAdapter(dbConnArgs)
  internalAd.setSchema(schema)
  internalAd.getConnection (e, db)->
    db.should.eql(dbMock)

  mongoClientMock.isCalled('connect').should.be.ok

errOnNoSchema = ()->
  ISAdapter = require '../../../../src/lib/adapters/internal_storage'

  mongoClientMock.modify 'connect',
    takes: [
      'mongodb://some_user:some_pass@some_server:some_port/some_db'
      ->
    ]
    calls: 1,
    with: [null, dbMock]
  
  internalAd = new ISAdapter(dbConnArgs)
  errFn = ()->
    internalAd.getOne(fields, filters, options, ->)

  errFn.should.throw('Schema is not defined')

getRecordsFromDB = ()->
  ISAdapter = require '../../../../src/lib/adapters/internal_storage'

  mongoClientMock.modify 'connect',
    takes: [
      'mongodb://some_user:some_pass@some_server:some_port/some_db'
      ->
    ]
    calls: 1,
    with: [null, dbMock]

  dbMock.modify 'collection',
    takes: ['some_table'],
    returns: dbMock

  dbMock.modify 'find',
    takes: (args)->
      args[0].should.eql(filters)
      args[1].should.eql(fields)
      return true
    returns: dbMock

  dbMock.modify 'toArray',
    takes: [->],
    calls: 0,
    with:[null, sampleRecords]

  internalAd = new ISAdapter(dbConnArgs)
  internalAd.setSchema(schema)

  internalAd.get fields, filters, options, (e, records)->
    e?.should.be.false
    records.should.be.instanceof(Array)
    records.should.eql(sampleRecords)

  mongoClientMock.isCalled('connect').should.be.ok
  dbMock.isCalled('collection').should.be.ok
  dbMock.isCalled('find').should.be.ok
  dbMock.isCalled('toArray').should.be.ok

getSingleRecordFromDB = ()->
  ISAdapter = require '../../../../src/lib/adapters/internal_storage'

  mongoClientMock.modify 'connect',
    takes: [
      'mongodb://some_user:some_pass@some_server:some_port/some_db'
      ->
    ]
    calls: 1,
    with: [null, dbMock]

  dbMock.modify 'collection',
    takes: ['some_table'],
    returns: dbMock

  dbMock.modify 'findOne',
    takes: (args)->
      args[0].should.eql(filters)
      args[1].should.eql(fields)
      return true
    calls: 2,
    with: [null, sampleRecord]

  internalAd = new ISAdapter(dbConnArgs)
  internalAd.setSchema(schema)

  internalAd.getOne fields, filters, (e, record)->
    e?.should.be.false
    record?.should.not.be.false
    record.should.not.be.instanceof(Array)
    record.should.eql(sampleRecord)

  mongoClientMock.isCalled('connect').should.be.ok
  dbMock.isCalled('collection').should.be.ok
  dbMock.isCalled('findOne').should.be.ok

insertRecord = ()->
  ISAdapter = require '../../../../src/lib/adapters/internal_storage'

  mongoClientMock.modify 'connect',
    takes: [
      'mongodb://some_user:some_pass@some_server:some_port/some_db'
      ->
    ]
    calls: 1,
    with: [null, dbMock]

   dbMock.modify 'collection',
    takes: ['some_table'],
    returns: dbMock

  dbMock.modify 'save',
    takes: [params, {safe:true, 'new':true}, ->],
    calls: 2,
    with: [null, params]
  
  internalAd = new ISAdapter(dbConnArgs)
  internalAd.setSchema(schema)
  internalAd.save params, (e, savedRecord)->
    e?.should.be.false
    savedRecord.should.eql(params)

  mongoClientMock.isCalled('connect').should.be.ok
  dbMock.isCalled('collection').should.be.ok
  dbMock.isCalled('save').should.be.ok

updateRecord = ()->
  ISAdapter = require '../../../../src/lib/adapters/internal_storage'

  mongoClientMock.modify 'connect',
    takes: [
      'mongodb://some_user:some_pass@some_server:some_port/some_db'
      ->
    ]
    calls: 1,
    with: [null, dbMock]

  dbMock.modify 'collection',
    takes: ['some_table'],
    returns: dbMock

  dbMock.modify 'update',
    takes: [
      filters,
      {$set: params}
      {safe:true, multi: true},
      ->
    ],
    calls: 3,
    with: [null]
  
  internalAd = new ISAdapter(dbConnArgs)
  internalAd.setSchema(schema)
  internalAd.update filters, params, (e)->
    e?.should.be.false

  mongoClientMock.isCalled('connect').should.be.ok
  dbMock.isCalled('collection').should.be.ok
  dbMock.isCalled('update').should.be.ok

upsertRecord = ()->
  ISAdapter = require '../../../../src/lib/adapters/internal_storage'

  mongoClientMock.modify 'connect',
    takes: [
      'mongodb://some_user:some_pass@some_server:some_port/some_db'
      ->
    ]
    calls: 1,
    with: [null, dbMock]

  dbMock.modify 'collection',
    takes: ['some_table'],
    returns: dbMock

  dbMock.modify 'update',
    takes: [
      filters,
      {$set: params}
      {safe:true, upsert: true},
      ->
    ],
    calls: 3,
    with: [null]
  
  internalAd = new ISAdapter(dbConnArgs)
  internalAd.setSchema(schema)
  internalAd.upsert filters, params, (e)->
    e?.should.be.false

  mongoClientMock.isCalled('connect').should.be.ok
  dbMock.isCalled('collection').should.be.ok
  dbMock.isCalled('update').should.be.ok

deleteRecord = ()->
  ISAdapter = require '../../../../src/lib/adapters/internal_storage'

  mongoClientMock.modify 'connect',
    takes: [
      'mongodb://some_user:some_pass@some_server:some_port/some_db'
      ->
    ]
    calls: 1,
    with: [null, dbMock]

  dbMock.modify 'collection',
    takes: ['some_table'],
    returns: dbMock

  dbMock.modify 'remove',
    takes: [filters, ->]
    calls: 1
    with: [null]

  internalAd = new ISAdapter(dbConnArgs)
  internalAd.setSchema(schema)

  internalAd.delete(filters, (e)->
    e?.should.be.false
  )

  mongoClientMock.isCalled('connect').should.be.ok
  dbMock.isCalled('collection').should.be.ok
  dbMock.isCalled('remove').should.be.ok

countRecord = ()->
  ISAdapter = require '../../../../src/lib/adapters/internal_storage'

  mongoClientMock.modify 'connect',
    takes: [
      'mongodb://some_user:some_pass@some_server:some_port/some_db'
      ->
    ]
    calls: 1,
    with: [null, dbMock]

  dbMock.modify 'collection',
    takes: ['some_table'],
    returns: dbMock

  dbMock.modify 'count',
    takes: [filters, ->]
    calls: 1
    with: [null, 'sm_cnt']

  internalAd = new ISAdapter(dbConnArgs)
  internalAd.setSchema(schema)
  internalAd.count(filters, (e, cnt)->
    e?.should.not.be.false
    cnt.should.eql('sm_cnt')
  )

  mongoClientMock.isCalled('connect').should.be.ok
  dbMock.isCalled('collection').should.be.ok
  dbMock.isCalled('count').should.be.ok

aggregateRecords = ()->
  ISAdapter = require '../../../../src/lib/adapters/internal_storage'

  mongoClientMock.modify 'connect',
    takes: [
      'mongodb://some_user:some_pass@some_server:some_port/some_db'
      ->
    ]
    calls: 1,
    with: [null, dbMock]

  dbMock.modify 'collection',
    takes: ['some_table'],
    returns: dbMock

  pipes = [
    $match: {'some_criterias'}
    $group: {'some_criterias'}
  ]

  dbMock.modify 'aggregate',
    takes: [pipes, ->]
    calls: 1
    with: [null, sampleRecords]

  internalAd = new ISAdapter(dbConnArgs)
  internalAd.setSchema(schema)
  internalAd.aggregate(pipes, (e, records)->
    e?.should.not.be.false
    records.should.eql(sampleRecords)
  )

  mongoClientMock.isCalled('connect').should.be.ok
  dbMock.isCalled('collection').should.be.ok
  dbMock.isCalled('aggregate').should.be.ok

convertIdToObject = ()->
  ISAdapter = require '../../../../src/lib/adapters/internal_storage'

  mongoClientMock.modify 'connect',
    takes: [
      'mongodb://some_user:some_pass@some_server:some_port/some_db'
      ->
    ]
    calls: 1,
    with: [null, dbMock]

  dbMock.modify 'collection',
    takes: ['some_table'],
    returns: dbMock

  dbMock.modify 'find',
    takes: (args)->
      args[0].should.have.property('_id')
      typeof(args[0]['_id']) is 'object'
      return true
    returns: dbMock

  dbMock.modify 'toArray',
    takes: [->],
    calls: 0,
    with:[null, [sampleRecord]]

  internalAd = new ISAdapter(dbConnArgs)
  internalAd.setSchema(schema)

  internalAd.get [], {_id: 'IdObject1'}, options, (e, records)->
    e?.should.be.false
    records.should.be.instanceof(Array)
    records.should.eql([sampleRecord])

  mongoClientMock.isCalled('connect').should.be.ok
  dbMock.isCalled('collection').should.be.ok
  dbMock.isCalled('find').should.be.ok
  dbMock.isCalled('toArray').should.be.ok

describe 'Data Adapter for MongoDB', ->
  beforeEach enableMockery
  afterEach disableMockery

  it 'should throw error if internal storage db config is not set', errOnNoISDBConfig
  it 'should connect to the Internal Storage DB', connectToInternalStorage
  it 'should throw error if schema is not set', errOnNoSchema
  it 'should get the records from the Internal Storage DB', getRecordsFromDB
  it 'should get the single record from the Internal Storage DB', getSingleRecordFromDB
  it 'should insert the records to the Internal Storage DB', insertRecord
  it 'should update the records to the Internal Storage DB', updateRecord
  it 'should upsert the records to the Internal Storage DB', upsertRecord
  it 'should delete the records to the Internal Storage DB', deleteRecord
  it 'should count the records in the Internal Storage DB', countRecord
  it 'should aggregate the records', aggregateRecords
  it 'should convert the id from string to object', convertIdToObject