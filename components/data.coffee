hub = require '../lib/hub'

data =
  to: 'Mr MacGoo and Partner'
  names: [
    'Mr MacGoo'
    ''
    ''
    ''
    ''
  ]

hub.every 'update name {index} to {name}', (p) ->
  console.log p


module.exports = data