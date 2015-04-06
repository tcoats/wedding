express = require 'express'
compression = require 'compression'
path = require 'path'
ql = require 'odoql/ql'
jsonstore = require 'odoql-json/store'

# stores =
#   organisations: jsonstore require './data/organisations'

app = express()

app.use compression()

oneDay = 1000 * 60 * 60 * 24
app.use express.static __dirname, maxAge: oneDay

# app.get '/query', (req, res) ->
#   query = JSON.parse req.query.q
#   ql.exec query, stores, (err, results) ->
#     if err?
#       res.status 400
#       res.json err
#       return
#     res.json results

app.get '/*', (req, res) ->
  console.log req.url
  res.sendFile path.join __dirname, 'index.html'

port = 8085
app.listen port

console.log "Wedding is listening on port #{port}..."