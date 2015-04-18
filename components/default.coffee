{ component, dom, widget } = require 'odojs'
inject = require 'injectinto'
ql = require 'odoql/ql'
hub = require 'odo-hub'

rsvp = component render: (state, params) ->
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
  for name, index in state.attending
    do (index) ->
      items.push nameinput name, (newname) ->
        hub.emit "{eventtitle} attendee {index} is {name}",
          eventtitle: params.eventtitle
          index: index
          name: newname
  
  checkboxattrs =
    type: 'checkbox'
  if state.going
    checkboxattrs.checked = 'checked'
  contents = [
    dom 'label', [
      dom 'span', "RSVP to the #{params.eventtitle}"
      dom 'input',
        attributes: checkboxattrs
        onchange: (e) ->
          hub.emit '{eventtitle} RSVP {attending}',
            eventtitle: params.eventtitle
            attending: e.target.checked
      dom 'span'
    ]
  ]
  if state.going
    contents.push dom 'div', [
      dom 'h4', 'Who is attending?'
      dom 'div', items
    ]
  dom 'div', contents

inject.bind 'page:default', component
  query: (params) ->
    invite: ql.query 'invites', 'asdf'
  render: (state, params) ->
    titileattr =
      attributes:
        class: 'title'
        src: '/title.png'
    dom 'div', { attributes: class: 'wrapper' }, [
      dom 'h1', state.invite.name
      dom 'img', titileattr
      rsvp state.invite['Pre Wedding Celebrations'],
        eventtitle: 'Pre Wedding Celebrations'
      rsvp state.invite['Wedding Ceremony'],
        eventtitle: 'Wedding Ceremony'
      rsvp state.invite['Wedding Reception'],
        eventtitle: 'Wedding Reception'
    ]