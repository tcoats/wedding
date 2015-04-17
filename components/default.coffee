{ component, dom, widget } = require 'odojs'
inject = require 'injectinto'
ql = require 'odoql/ql'

attending = component render: (state, params) ->
  nameinput = ->
    dom 'div', [
      dom 'input',
        attributes:
          type: 'text'
          autocomplete: 'off'
          autocorrect: 'off'
    ]
  
  dom 'div', [
    dom 'div', [
      dom 'label', [
        dom 'input',
          attributes:
            type: 'checkbox'
        dom 'span'
        dom 'span', "RSVP to the #{params.title}"
      ]
    ]
    dom 'h4', 'Who is attending?'
    nameinput()
    nameinput()
    nameinput()
    nameinput()
  ]



inject.bind 'page:default', component
  render: (state, params) ->
    titileattr =
      attributes:
        class: 'title'
        src: '/title.png'
    dom 'div', { attributes: class: 'wrapper' }, [
      dom 'h1', 'Joe Bloggs'
      dom 'img', titileattr
      attending {}, title: 'Pre Wedding Celebrations'
      attending {}, title: 'Wedding Ceremony'
      attending {}, title: 'Wedding Reception'
    ]