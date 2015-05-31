{ svg, component } = require 'odojs'
inject = require 'injectinto'
require 'svg4everybody'
pjson = require '../package.json'

Gift = component render: ->
  svg 'svg', { attributes: role: 'img', class: 'gift' }, [
    svg 'use', { 'xlink:href': "/dist/#{pjson.name}-#{pjson.version}.min.svg#gift" }
  ]

inject.bind 'gift', Gift
module.exports = Gift