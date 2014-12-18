errOnNoConnectionMethod = ()->
  Adapter = require '../../../../src/lib/adapters'

  adapter = new Adapter()
  errFn = ()->
    adapter.getConnection({'db_conn_args'}, ->)
  errFn.should.throw('getConnection method is not defined in subclass')

errOnNoGetMethod = ()->
  Adapter = require '../../../../src/lib/adapters'

  adapter = new Adapter()
  errFn = ()->
    adapter.get({'get_args'}, ->)
  errFn.should.throw('get method is not defined in subclass')

errOnNoGetOneMethod = ()->
  Adapter = require '../../../../src/lib/adapters'

  adapter = new Adapter()
  errFn = ()->
    adapter.getOne(->)
  errFn.should.throw('getOne method is not defined in subclass')

errOnNoSaveMethod = ()->
  Adapter = require '../../../../src/lib/adapters'

  adapter = new Adapter()
  errFn = ()->
    adapter.save({'save_args'}, ->)
  errFn.should.throw('save method is not defined in subclass')

errOnNoUpdateMethod = ()->
  Adapter = require '../../../../src/lib/adapters'

  adapter = new Adapter()
  errFn = ()->
    adapter.update(->)
  errFn.should.throw('update method is not defined in subclass')

errOnNoDeleteMethod = ()->
  Adapter = require '../../../../src/lib/adapters'

  adapter = new Adapter()
  errFn = ()->
    adapter.delete(->)
  errFn.should.throw('delete method is not defined in subclass')

errOnNoCountMethod = ()->
  Adapter = require '../../../../src/lib/adapters'

  adapter = new Adapter()
  errFn = ()->
    adapter.count(->)
  errFn.should.throw('count method is not defined in subclass')

errOnNoCloseMethod = ()->
  Adapter = require '../../../../src/lib/adapters'

  adapter = new Adapter()
  errFn = ()->
    adapter.close(->)
  errFn.should.throw('close method is not defined in subclass')

configure = ()->
  Adapter = require '../../../../src/lib/adapters'
  
  adapter = new Adapter({'db_conn_settings'})
  adapter.options.should.eql({'db_conn_settings'})

  adapter.configure({'db_conn_settings2'})
  adapter.options.should.eql({'db_conn_settings2'})

setSchema = ()->
  Adapter = require '../../../../src/lib/adapters'

  adapter = new Adapter()
  adapter.setSchema({'modified_schema_details'})
  adapter.schema.should.eql({'modified_schema_details'})

getSchema = ()->
  Adapter = require '../../../../src/lib/adapters'

  adapter = new Adapter()
  errFn = ()->
    adapter.getSchema()
  errFn.should.throw('Schema is not defined')

  adapter.setSchema({'some_schema'})
  errFn2 = ()->
    adapter.getTableName()
  errFn2.should.throw('Table name is not mentioned in the schema')
  errFn3 = ()->
    adapter.getFields()
  errFn3.should.throw('Fields are not mentioned in the schema')
  errFn4 = ()->
    adapter.getIdFieldName()
  errFn4.should.throw('Id Field name is not mentioned in the schema')

  schema = {
    fields: {'some_fields'}
    table: {'table_name'}
    id: {'id_field_name'}
  }
  adapter.setSchema(schema)
  adapter.getSchema().should.eql(schema)
  adapter.getTableName().should.eql(schema.table)
  adapter.getFields().should.eql(schema.fields)
  adapter.getIdFieldName().should.eql(schema.id)

describe 'Data Adapter', ->
  it 'should throw exception if getConnection method is not defined in the subclass', errOnNoConnectionMethod
  it 'should throw exception if get method is not defined in the subclass', errOnNoGetMethod
  it 'should throw exception if getOne method is not defined in the subclass', errOnNoGetOneMethod
  it 'should throw exception if save method is not defined in the subclass', errOnNoSaveMethod
  it 'should throw exception if update method is not defined in the subclass', errOnNoUpdateMethod
  it 'should throw exception if delete method is not defined in the subclass', errOnNoDeleteMethod
  it 'should throw exception if count method is not defined in the subclass', errOnNoCountMethod
  it 'should throw exception if close method is not defined in the subclass', errOnNoCloseMethod
  it 'should configure the adapter', configure
  it 'should set the schema', setSchema
  it 'should get the schema', getSchema
