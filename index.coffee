express = require 'express'
compression = require 'compression'
bodyParser = require 'body-parser'

app = express()

app.use compression()
app.use bodyParser.urlencoded extended: yes
app.use bodyParser.json()

oneDay = 1000 * 60 * 60 * 24
app.use express.static __dirname, maxAge: oneDay

loadinvite = (key, value) -> (cb) ->


path = require 'path'
CSON = require 'cson'
store = require 'odoql-store'
store = store()
  .use 'invite', (params, cb) ->
    filename = "#{params}.cson"
    file = path.join __dirname, 'data', filename
    CSON.load file, (err, results) ->
      if err?
        console.log err
        return cb err
      cb null, results

Exe = require 'odoql-exe'
buildqueries = require 'odoql-exe/buildqueries'
queryexe = Exe()
  .use store
app.post '/query', (req, res, next) ->
  run = buildqueries queryexe, req.body.q
  run (errors, results) ->
    return next errors if errors?
    res.send results

fs = require 'fs'
app.post '/submit', (req, res) ->
  filename = "#{req.query.code}.cson"
  filepath = path.join __dirname, 'data', filename
  data = CSON.stringify req.body
  #console.log data
  fs.writeFile filepath, data, (err) ->
    throw err if err?
    res.end 'ok'

app.get '/*', (req, res) ->
  res.sendFile path.join __dirname, 'index.html'

port = 8085
app.listen port

console.log "Wedding is listening on port #{port}..."