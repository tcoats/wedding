inject = require './inject'

bind = ->
  class Statistics
    constructor: ->
      @stats = {}
      @derived = {}
      inject.bind 'stat abs', @absolute
      inject.bind 'stat rel', @relative
      inject.bind 'stat notify', @notify
    
    absolute: (entity, values) =>
      for key, value of values
        #console.log "#{key}: #{value}"
        @stats[key] = 0 if !@stats[key]?
        if @derived[key]?
          current = @stats[key]
          for derived in @derived[key]
            derived entity, current, value
        @stats[key] = value
    
    relative: (entity, values) =>
      for key, value of values
        @stats[key] = 0 if !@stats[key]?
        p = {}
        p[key] = @stats[key] + value
        @absolute entity, p
    
    notify: (key, cb) =>
      @derived[key] = [] if !@derived[key]?
      @derived[key].push cb
      off: =>
        index = @derived[key].indexOf(cb)
        @derived[key].splice index, 1 if index isnt -1
  
  new Statistics

if define?
  define [], bind
else if module?
  module.exports = bind()
else
  window.statistics = bind()