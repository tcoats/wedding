{ component, dom, svg } = require 'odojs'
inject = require 'injectinto'

inject.bind 'page:error', component render: (state, params) ->
  dom 'div', { attributes: class: 'wrapper error grid grid--center' }, [
    dom 'div', [
      dom 'div', { attributes: class: 'logo' }, [
        svg 'svg', { width: '128', height: '128' }, [
          svg 'use', { 'xlink:href': '/dist/nextgen-1.0.0.min.svg#forecast-flat' }
        ]
      ]
      dom 'div', [
        dom 'h1', params.page.message
        dom 'p', params.page.details
      ]
    ]
  ]