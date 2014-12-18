_ = require 'underscore'
moment = require 'moment'

class Util

  @obscureCredentials: (params, obscFields)->
    obscParams = {}
    _.each(params, (val, key)->
      if _.indexOf(obscFields, key) > -1
        obscParams[key] = '********'
      else
        obscParams[key] = val
    )

    return obscParams

  @clone: (object)->
    return JSON.parse(JSON.stringify(object))

  @getNoDaysSince: (date)->
    qntDiff = moment().diff(moment(date), 'days')

    return "#{qntDiff} Day" if qntDiff is 1
    return "#{qntDiff} Days"

  @getFirstNWords: (str, noWords)->
    return '' unless str?
    strArr = str.split(' ')
    totalWords = strArr.length
    strArr = _.first strArr, noWords
    str = strArr.join(' ')
    str = str + '...' if totalWords > noWords
    return str 

  @getFirstNChars: (str, noChars)->
    return '' unless str?
    str = str.substring(0, (noChars-3)) + '...' if str.length > noChars
    return str

module.exports = Util