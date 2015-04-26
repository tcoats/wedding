{ component, dom, widget } = require 'odojs'
inject = require 'injectinto'
ql = require 'odoql/ql'
hub = require 'odo-hub'
form2js = require '../plumbing/form2js'
emblem = require './emblem'

rsvp = component render: (state, params) ->
  nameinput = (index, name, cb) ->
    dom 'div', [
      dom 'input',
        onkeyup: (e) ->
          cb e.target.value if e.keyCode is 13
        onblur: (e) ->
          cb e.target.value
        attributes:
          name: "#{params.eventid}.attending[#{index}]"
          type: 'text'
          autocomplete: 'off'
          autocorrect: 'off'
          autocapitalize: 'off'
          value: name
    ]
  
  items = []
  for name, index in state.attending
    do (index) ->
      items.push nameinput index, name, (newname) ->
        hub.emit "{eventid} attendee {index} is {name}",
          eventid: params.eventid
          index: index
          name: newname
  
  checkboxattrs =
    name: "#{params.eventid}.going"
    type: 'checkbox'
    value: 'true'
  if state.going
    checkboxattrs.checked = 'checked'
  contents = [
    dom 'label', [
      dom 'span', "RSVP to the #{params.eventtitle}"
      dom 'input',
        attributes: checkboxattrs
        onchange: (e) ->
          hub.emit '{eventid} RSVP {attending}',
            eventid: params.eventid
            attending: e.target.checked
      dom 'span'
    ]
  ]
  whoattrs = {}
  if not state.going
    whoattrs.style = 'display: none;'
  
  contents.push dom 'div', attributes: whoattrs, [
    dom 'h4', 'Who is attending?'
    dom 'div', items
  ]
  dom 'div', contents

inject.bind 'page:default', component
  query: (params) ->
    invite: ql.query 'invites', 'asdf'
  render: (state, params) ->
    submit = (e) ->
      data = form2js e.target, null, no
      console.log JSON.stringify data, null, 2
      e.preventDefault()
    titileattr =
      attributes:
        class: 'title'
        src: '/title.png'
    dom 'div', { attributes: class: 'wrapper' }, [
      dom 'div', { attributes: class: 'nb nb-top' }, [
        emblem()
      ]
      dom 'div', { attributes: class: 'nb nb-section' }, [
        dom 'h1', state.invite.to
        # dom 'img', titileattr
        dom 'form', { onsubmit: submit }, [
          rsvp state.invite['prewedding'],
            eventid: 'prewedding'
            eventtitle: 'Pre Wedding Celebrations'
          rsvp state.invite['ceremony'],
            eventid: 'ceremony'
            eventtitle: 'Wedding Ceremony'
          rsvp state.invite['reception'],
            eventid: 'reception'
            eventtitle: 'Wedding Reception'
          dom 'input',
            attributes:
              type: 'submit'
              value: 'Go'
        ]
      ]
      dom 'div', { attributes: class: 'nb nb-bottom' }, [
        emblem()
      ]
    ]