Adapter = require './index'
fs = require 'fs-extra'
ObjectID = require('mongodb').ObjectID
_ = require 'underscore'
path = require 'path'

class FileStorageAdapter extends Adapter

  # 
  # ## configure
  # configure the directory path at which storage file needs be created
  # 
  # @param {string} dirPath, absolute path for the directory
  configure: (dirPath)->
    @fileStoragePath = dirPath

  # 
  # ## getFileStoragePath
  # returns the filename with abolute path in which the data is saved
  getFileStoragePath: ()->
    throw new Error 'File Storage path is not configured' unless @fileStoragePath?

    return path.resolve(@fileStoragePath + '/' + @getTableName())

  # 
  # ## getOne
  # queries the records from the table(defined in the schema)
  # 
  # @param {object} fields, Select fields with [col_name1, col_name2]
  # @param {object} filterValues, Filtering fields with [{col_name: 'value'}]
  getOne: (fields, filters, cb)->
    filePath = @getFileStoragePath()
    
    fs.readJson filePath, (e, records)->
      return cb(e, null) if e?

      foundRec = _.findWhere(records, filters)
      if foundRec?
        foundRec = _.pick(foundRec, fields)
        return cb(null, foundRec)
      
      cb(null, null)

  # 
  # ## get
  # queries the records from the table(defined in the schema)
  # 
  # @param {object} fields, Select fields with [col_name1, col_name2]
  # @param {object} filterValues, Filtering fields with [{col_name: 'value'}]
  # @param {object} options, not yet implemented
  get: (fields, filters, options, cb)->
    @getOne fields, filters, (e, record)->
      return cb(e, null) if e?

      return cb(null, [record]) if record?

      cb(null, [])

  # 
  # ## save
  # inserts a new document
  # 
  # @param {object} params, Fields with [{col_name1:value1}, {col_name2:value2}]
  save: (params, cb)->
    filePath = @getFileStoragePath()

    params = _.extend({_id: new ObjectID()}, params)
    
    fs.outputJson filePath, [params], (e)->
      cb(e)

module.exports = FileStorageAdapter