mkry = require 'mockery'
fsMock = mock ['readJson', 'outputJson']

enableMockery = ()->
  mkry.registerMock 'fs-extra', fsMock
  mkry.enable warnOnUnregistered: false, warnOnReplace: false, useCleanCache: true

disableMockery = ()->
  mkry.deregisterAll()
  mkry.disable()

path = '/some_dir'
schema = {table: 'some_table'}
filePath = "#{path}/#{schema.table}"
fields = ['some_fields']
filters = {'some_fields': 'some_value'}
options = {'not_implemented'}

errOnFileStorageNotConfigured = ()->
  FileStorage = require '../../../../src/lib/adapters/file_storage'

  fileStorage = new FileStorage()
  errFn = ()->
    fileStorage.getOne(fields, filters, options, ->)
  errFn.should.throw('File Storage path is not configured')

errOnNoSchema = ()->
  FileStorage = require '../../../../src/lib/adapters/file_storage'

  fileStorage = new FileStorage(path)
  errFn = ()->
    fileStorage.get(fields, filters, options, ->)
  errFn.should.throw('Schema is not defined')

getFileStoragePath = ()->
  FileStorage = require '../../../../src/lib/adapters/file_storage'

  fileStorage = new FileStorage(path)
  fileStorage.setSchema(schema)

  fileStorage.getFileStoragePath().should.eql('/some_dir/some_table')

createRecords = ()->
  FileStorage = require '../../../../src/lib/adapters/file_storage'

  fsMock.modify 'outputJson',
    takes: (args)->
      return args[0].should.eql(filePath) and 
        args[1].should.be.an.instanceOf(Array) and
        args[1][0].should.have.property('some_fields') and
        args[1][0].should.have.property('_id').instanceof(require('mongodb').ObjectID)
    calls: 2
    with: [null]

  fileStorage = new FileStorage(path)
  fileStorage.setSchema(schema)

  fileStorage.save({'some_fields': 'some_value'}, ->)
  fsMock.isCalled('outputJson').should.be.ok

getRecords = ()->
  FileStorage = require '../../../../src/lib/adapters/file_storage'

  fsMock.modify 'readJson',
    takes: (args)->
      return args[0].should.eql(filePath)
    calls: 1
    with: [null, [{'some_fields': 'some_value'}]]

  fileStorage = new FileStorage(path)
  fileStorage.setSchema(schema)

  fileStorage.get(fields, {'wrong_filter'}, options, (e, records)->
    e?.should.be.false 
    records?.should.be.an.instanceOf(Array)
    records.length.should.eql(0)
  )
  fsMock.isCalled('readJson').should.be.ok

  fsMock.reset()
  fileStorage.get(fields, filters, options, (e, records)->
    e?.should.be.false  
    records.should.be.an.instanceOf(Array)
    records.length.should.eql(1)
    records[0].should.have.property('some_fields')
  )
  fsMock.isCalled('readJson').should.be.ok

getOneRecord = ()->
  FileStorage = require '../../../../src/lib/adapters/file_storage'

  fsMock.modify 'readJson',
    takes: (args)->
      return args[0].should.eql(filePath)
    calls: 1
    with: [null, [{'some_fields': 'some_value'}]]

  fileStorage = new FileStorage(path)
  fileStorage.setSchema(schema)

  fileStorage.getOne(fields, {'wrong_filter'}, (e, record)->
    e?.should.be.false
    record?.should.be.false
  )
  fsMock.isCalled('readJson').should.be.ok

  fsMock.reset()
  fileStorage.getOne(fields, filters, (e, record)->
    e?.should.be.false 
    record.should.be.an.instanceOf(Object)
    record.should.not.be.an.instanceOf(Array)
    record.should.have.property('some_fields')
    record['some_fields'].should.eql('some_value')
  )
  fsMock.isCalled('readJson').should.be.ok

describe 'File Storage Adapter', ->
  before enableMockery
  after disableMockery

  it 'should throw error if File store path is not configured', errOnFileStorageNotConfigured
  it 'should throw error if schema is not defined', errOnNoSchema
  it 'should get the file storage path', getFileStoragePath
  it 'should save the records in the file', createRecords
  it 'should get the saved records from the file', getRecords
  it 'should get one saved record from the file', getOneRecord