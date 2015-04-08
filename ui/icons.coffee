{ component, dom, svg } = require 'odojs'
inject = require 'injectinto'
require 'svg4everybody'

Icon = component
  render: (state, params) ->
    dom 'span', [
      svg 'svg', { attributes: role: 'img', class: 'icon' }, [
        svg 'use', { 'xlink:href': "/dist/wedding-1.0.0.min.svg##{params.i}" }
      ]
    ]

inject.bind 'icon', Icon
module.exports = Icon