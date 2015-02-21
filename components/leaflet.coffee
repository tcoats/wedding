{ component, dom } = require '../lib/deku.min'
L = require '../lib/leaflet-src.js'

module.exports = component
  afterMount: (el, props, state) ->
    map = L.map el
      .setView [51.505, -0.09], 8
    tiles = L.tileLayer 'http://otile{s}.mqcdn.com/tiles/1.0.0/sat/{z}/{x}/{y}.jpg',
      maxZoom: 10
      attribution: ''
      subdomains: '1234'
    tiles.addTo map
    
    invalidateSize = -> map.invalidateSize()
    
    @setState
      map: map
      tiles: tiles
      , invalidateSize
  
  beforeUnmount: (el, props, state) ->
    state.map.remove()
  
  render: (props, state) ->
    dom 'div', id: 'map'