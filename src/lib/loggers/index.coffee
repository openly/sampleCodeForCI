class Logger
  log: (content)->
    throw new Error 'Log method is not defined'

module.exports = Logger