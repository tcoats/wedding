# odo-relay and odo-exe use an optional odo-hub for logging and statistics
hub = require 'odo-hub'

# Configure Odo.js with mixins
{ component, widget, hook } = require 'odojs'
odoql = require 'odoql/odojs'
component.use odoql
widget.use odoql
hook.use odoql

# Setup client odoql execution providers
# TODO add providers here to give components more query options
# e.g. exe.use require 'odoql-csv'
dynamic = require 'odoql-exe/dynamic'
exe = require 'odoql-exe'
exe = exe hub: hub
  .use dynamic (keys, queries, cb) ->
    request = require 'superagent'
    request
      .post '/query'
      .send q: queries
      .set 'Accept', 'application/json'
      .end (err, res) ->
        return cb err if err?
        return cb new Error res.text unless res.ok
        result = {}
        for key in keys
          result[key] = res.body[key]
        cb null, result

# Shared components register against injectinto
require '../components/'

page = require 'page'
inject = require 'injectinto'
# Here is our router. This works on first request and any 'virtual' requests from then on. The server is normally configured to return the same index.html file for all urls that don't match physical files so a manual refresh also works. It's pretty cool.
page '/', (e) ->
  hub.emit 'navigate to the front page'
page '/:code', (e) ->
  hub.emit 'navigate to the default page', e.params
page (details) ->
  hub.emit 'navigation error, {pathname} not found', details

getpage = (params) ->
  page = params.page ? 'default'
  page = page.name if page instanceof Object
  inject.one "page:#{page}"

Router = component
  query: (params) ->
    getpage(params).query params
  render: (state, params) ->
    getpage(params) state, params

# Setup odo relay against the root router component
# Discover queries, state and dom elements already built on the server
relay = require 'odo-relay'
root = document.querySelector '#root'
scene = relay root, Router, exe,
  queries: window.__queries
  state: window.__state
  hub: hub

# Load routes into page.js for pushstate routing
# route = require 'odo-route'
# page = require 'page'
# for route in route.routes()
#   do (route) ->
#     page route.pattern, (e) ->
#       scene.update route.cb
#         url: e.pathname
#         params: e.params

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

hub.every 'show bank details', (p, cb) ->
  scene.update showbankdetails: yes
  cb()

hub.every 'event submit {code} success', (p, cb) ->
  scene.update success: yes
  cb()

request = require 'superagent'
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

# Detect the current url and run scene.update for the first time

page()

# Remove the loading element so the timeout detector knows we loaded successfully
body = document.querySelector 'body'
loading = document.querySelector '#loading'
body.removeChild loading