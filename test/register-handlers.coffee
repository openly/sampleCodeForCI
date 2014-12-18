require("coffee-coverage").register
  path: "relative"
  basePath: __dirname + '/../src'
  exclude: ['web_app/controller/', 'app.coffee'] # exclude the directories/files from base path
  initAll: true