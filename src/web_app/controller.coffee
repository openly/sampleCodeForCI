Controller = require '../lib/controller'
_ = require 'underscore'

class WebAppController extends Controller
  constructor: ()->
    super()

  getMustacheDefaultValues: ()->
    unless @defaultRenderValues?
      @defaultRenderValues = {
        'static_url': '/static'
      }
    return @defaultRenderValues

  mergeDefRenderValues: (values)->
    renderValues = {}
    _.extend(renderValues, @getMustacheDefaultValues(), values)
    return renderValues

module.exports = WebAppController