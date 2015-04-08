{ component, dom, widget, svg } = require 'odojs'
inject = require 'injectinto'
ql = require 'odoql/ql'

inject.bind 'page:default', component
  render: (state, params) ->
    titileattr =
      attributes:
        class: 'title'
      style:
        width: '100%'
    dom 'div', { attributes: class: 'wrapper' }, [
      dom 'h1', 'Joe Bloggs'
      svg 'svg', titileattr, [
        svg 'use', { 'xlink:href': "/dist/wedding-1.0.0.min.svg#title" }
      ]
    ]