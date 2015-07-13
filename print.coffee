fs = require 'fs'
path = require 'path'
CSON = require 'cson'

eventids = ['prewedding', 'ceremony', 'reception', 'breakfast']

attending = {}
for id in eventids
  attending[id] = []

notresponded = []

files = fs.readdirSync './data'
for file in files
  continue if path.extname(file) isnt '.cson'
  contents = CSON.load "./data/#{file}"

  hasmodifier = no
  keys = Object.keys contents
  if keys[1] is 'comments'
    notresponded.push contents.to

  going = no
  for id in eventids
    continue unless contents[id]
    going = going or contents[id].going
    for a in contents[id].attending
      continue if a is ''
      attending[id].push a

  continue unless going

  output = "#{contents.to}:"
  for id in eventids
    continue unless contents[id]
    continue unless contents[id].going
    output += " #{id}"

  console.log output

console.log()

console.log 'Not responded:'
for person in notresponded
  console.log "  #{person}"

console.log()

for id, people of attending
  console.log "#{id} (#{people.length}):"
  for person in people
    console.log "  #{person}"
  console.log()
