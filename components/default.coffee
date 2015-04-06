{ component, dom, widget } = require 'odojs'
inject = require 'injectinto'
ql = require 'odoql/ql'

inject.bind 'page:default', component
  render: (state, params) ->
    dom 'div', { attributes: class: 'wrapper grid' }, [
      'HELLO THERE'
    ]