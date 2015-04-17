{ component, dom, widget } = require 'odojs'
inject = require 'injectinto'
ql = require 'odoql/ql'
hub = require 'odo-hub'

attending = component render: (names, params) ->
  nameinput = (name, cb) ->
    dom 'div', [
      dom 'input',
        onkeyup: (e) ->
          cb e.target.value if e.keyCode is 13
        onblur: (e) ->
          cb e.target.value
        attributes:
          type: 'text'
          autocomplete: 'off'
          autocorrect: 'off'
          autocapitalize: 'off'
          value: name
    ]
  
  items = []
  for name, index in names
    do (index) ->
      items.push nameinput name, (newname) ->
        console.log "EDITED #{index}"
  items.push nameinput '', (name) ->
    if name isnt ''
      console.log 'NEW ITEM'
  
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
    dom 'div', items
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
      attending ['Joe Bloggs'], title: 'Pre Wedding Celebrations'
      attending ['Joe Bloggs'], title: 'Wedding Ceremony'
      attending ['Joe Bloggs'], title: 'Wedding Reception'
    ]