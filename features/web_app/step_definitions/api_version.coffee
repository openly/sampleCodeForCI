require('should')

versionSDWrapper = ->
  @World = require("../support/world.coffee").World # overwrite default World constructor

  response = null
  @When /^I request the url '\/'$/, (callback) ->
    @getVisit('/', (e, resp)->
      response = resp.body
      callback()
    )
    return

  @Then /^I should get the response with version number$/, (callback) ->
    response.should.containEql('Web App with version 0.0.1')
    callback()
    return

  return

module.exports = versionSDWrapper