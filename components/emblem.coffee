{ svg, component } = require 'odojs'
inject = require 'injectinto'
require 'svg4everybody'
pjson = require '../package.json'

Emblem = component render: ->
  svg 'svg', { attributes: role: 'img', class: 'emblem' }, [
    svg 'use', { 'xlink:href': "/dist/#{pjson.name}-#{pjson.version}.min.svg#emblem" }
  ]

inject.bind 'emblem', Emblem
module.exports = Emblem