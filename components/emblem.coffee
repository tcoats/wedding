{ svg, component } = require 'odojs'
inject = require 'injectinto'
require 'svg4everybody'

Emblem = component render: ->
  svg 'svg', { attributes: role: 'img', class: 'emblem' }, [
    svg 'use', { 'xlink:href': "/dist/wedding-1.0.0.min.svg#emblem" }
  ]

inject.bind 'emblem', Emblem
module.exports = Emblem