fs = require 'fs'
path = require 'path'
CSON = require 'cson'

files = fs.readdirSync './data'
for file in files
  continue if path.extname(file) isnt '.cson'
  contents = CSON.load "./data/#{file}"

  hasmodifier = no
  keys = Object.keys contents
  continue unless keys[1] is 'comments'
  console.log contents.to

  continue

  going = no
  for id in ['prewedding', 'ceremony', 'reception', 'breakfast']
    continue unless contents[id]
    going = going or contents[id].going
  continue unless going

  output = "#{contents.to}:"
  for id in ['prewedding', 'ceremony', 'reception', 'breakfast']
    continue unless contents[id]
    continue unless contents[id].going
    output += " #{id}"

  console.log output
  #console.log JSON.stringify contents, null, 2
