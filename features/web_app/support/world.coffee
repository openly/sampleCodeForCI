Browser = require("zombie")

World = (callback) ->
  browser = new Browser()

  #set url from the environment variables
  url = process.env['url']

  if url is undefined
    switch process.env['NODE_ENV']
      when 'development' then url = 'http://localhost:3001'
      when 'test' then url = 'http://localhost:3002'
      when 'stage' then url = 'http://localhost:3003'
      when 'production' then url = 'http://localhost:3004'
      #To Do: add for some other environments
      else url = 'http://localhost:3001'

  browser.site = url
  browser.waitDuration = '10s'

  @visit = (method, args)->
    path = args[0]
    argLen = args.length
    cb = args[argLen-1]

    if args.length == 2
      options = {}
    else if args.length == 3
      options = {
        params: args[1]
      }
    else if args.length >= 4
      options = {
        params: args[1]
        headers: args[2]
      }

    browser.resources.request(method, path, options, (e, response)->
      throw e if e?
      cb(null, response)
    )

  #params passed in order
  # path, [params], [headers], callback
  # params and headers are optional
  @getVisit = () ->
    @visit('GET', arguments)

  @postVisit = () ->
    @visit('POST', arguments)

  callback() # tell Cucumber we're finished and to use 'this' as the world instance

  return

exports.World = World