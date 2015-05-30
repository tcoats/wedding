{ svg, component } = require 'odojs'
inject = require 'injectinto'
require 'svg4everybody'

Gift = component render: ->
  svg 'svg', { attributes: role: 'img', class: 'gift' }, [
    svg 'use', { 'xlink:href': "/dist/wedding-1.0.0.min.svg#gift" }
  ]

inject.bind 'gift', Gift
module.exports = Gift