MongoClient = require("mongodb").MongoClient

MongoClient.connect "mongodb://openly:indian@127.0.0.1:27017/ITC_InternalStorage", (err, db) ->
  throw err  if err
  collection = db.collection("test_insert")
  collection.insert {a: 2}, (err, docs) ->
    collection.count (err, count) ->
      console.log ("count = #{count}")

    # Locate all the entries using find
    collection.find().toArray (err, results) ->
      console.dir results
      
      # Let's close the db
      db.close()
      return

    return

  return
