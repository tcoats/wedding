###
  Register things to do when various events fire
###
hub = require 'odo-hub'
scene = require './scene'

# Log all events, with special logging for queries
hub.all (e, description, p, cb) ->
  if e is 'queries starting'
    console.log "? #{p.description}"
  else if e is 'queries completed'
    timings = Object.keys(p)
      .map (prop) ->
        "  #{prop} in #{p[prop]}ms"
      .join '\n'
    console.log "√ completed\n#{timings}"
  else
    console.log "+ #{description}"
  cb()

hub.every '{eventid} RSVP {attending}', (p, cb) ->
  delta = invite: {}
  delta.invite[p.eventid] = going: p.attending
  transaction = scene.layer delta
  scene.update()
  cb()

hub.every '{eventid} attendee {index} is {name}', (p, cb) ->
  
  cb()

# Navigation
hub.every 'navigate to the default page', (p, cb) ->
  scene.update page: name: 'default', code: p.code
  cb()

hub.every 'navigation error, {pathname} not found', (p, cb) ->
  scene.update page:
    name: 'error'
    message: "#{p.pathname} not found"
  cb()
