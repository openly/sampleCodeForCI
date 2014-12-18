Controller = require '../controller'

class IndexController extends Controller
  setupRoutes: (server) ->
    server.get('/', @index)

  index: (req, res, next)=>
    renderValues = {
      page_title: 'Version'
      version: '0.0.1'
    }

    renderValues = @mergeDefRenderValues(renderValues)
    res.render('index', renderValues)

module.exports = IndexController