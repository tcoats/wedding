express = require 'express'
compression = require 'compression'
path = require 'path'
ql = require 'odoql/ql'
async = require 'odo-async'
CSON = require 'cson'

stores =
  invites: (query, callback) ->
    try
      result = {}
      tasks = []
      loadinvite = (key, value) -> (cb) ->
        filename = "#{value.__params}.cson"
        file = path.join __dirname, 'data', filename
        CSON.load file, (err, results) ->
          if err?
            console.log err
            return cb()
          console.log filename
          console.log results
          result[key] = results
          cb()
      for key, value of query
        tasks.push loadinvite key, value
      async.parallel tasks, -> callback null, result
    catch e
      console.log e
      callback e
    ->

app = express()

app.use compression()

oneDay = 1000 * 60 * 60 * 24
app.use express.static __dirname, maxAge: oneDay

app.get '/query', (req, res) ->
  query = JSON.parse req.query.q
  ql.exec query, stores, (err, results) ->
    if err?
      res.status 400
      res.json err
      return
    res.json results

app.get '/*', (req, res) ->
  console.log req.url
  res.sendFile path.join __dirname, 'index.html'

port = 8085
app.listen port

console.log "Wedding is listening on port #{port}..."