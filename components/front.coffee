{ component, dom, svg } = require 'odojs'
inject = require 'injectinto'

inject.bind 'page:front', component render: (state, params) ->
  titileattr =
    attributes:
      class: 'title'
    style:
      width: '100%'
  dom 'div', { attributes: class: 'wrapper error grid grid--center' }, [
    dom 'div', [
      dom 'div', { attributes: class: 'logo' }, [
        svg 'svg', titileattr, [
          svg 'use', { 'xlink:href': "/dist/wedding-1.0.0.min.svg#emblem" }
        ]
      ]
      dom 'div', [
        dom 'h1', 'Thomas Coats and Harvinder Kaur'
        dom 'p', "You will need an invite code to RSVP"
      ]
    ]
  ]
