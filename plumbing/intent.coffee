###
  Register things to do when various events fire
###
hub = require 'odo-hub'
scene = require './scene'
request = require 'superagent'
xhr = require 'xhr'

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
  scene.state().invite[p.eventid].going = p.attending
  scene.update()
  cb()

hub.every '{eventid} attendee {index} is {name}', (p, cb) ->
  scene.state().invite[p.eventid].attending[p.index] = p.name
  scene.update()
  cb()

# Navigation
hub.every 'navigate to the default page', (p, cb) ->
  scene.update page: name: 'default', code: p.code
  cb()

hub.every 'navigate to the front page', (p, cb) ->
  scene.update page: name: 'front'
  cb()

hub.every 'navigation error, {pathname} not found', (p, cb) ->
  scene.update page:
    name: 'error'
    message: "Sorry, the \"#{p.pathname}\" page was not found."
  cb()

hub.every 'event error, {code} not found', (p, cb) ->
  scene.update page:
    name: 'error'
    message: "Sorry, the event code \"#{p.code}\" was not found."
  cb()

hub.every 'event error, {code} submit failed', (p, cb) ->
  scene.update page:
    name: 'error'
    message: 'Sorry, something went wrong. Refresh to try again?'
  cb()

hub.every 'event submit {code} success', (p, cb) ->
  scene.update success: yes
  cb()

hub.every 'event code {code} submitted', (p, cb) ->
  require('page').stop()
  request
    .post '/submit'
    .query code: p.code
    .send p.data
    .end (err, res) ->
      cb()
      if err? or !res.ok
        console.error err
        hub.emit 'event error, {code} submit failed', p
        return
      hub.emit 'event submit {code} success', p

