{ component, dom } = require '../lib/deku.min'
data = require './data'

Checkbox = component
  render: (props) ->
    dom 'label', [
      dom 'input', { type: 'checkbox', name: props.name, value: props.value }
      props.text
      dom 'br'
    ]

Checkboxes = component
  render: (props) ->
    contents = [
      dom 'legend', props.text
    ]
    contents = contents.concat props.checkboxes.map (p) -> Checkbox p
    dom 'fieldset', contents

NamesList = component
  render: ->
    content = [
      dom 'legend', 'Names'
    ]
    for d, i in data.names
      content.push dom 'label', [
        "#{i+1}. "
        dom 'input', { type: 'text', name: "name-#{i}", value: d }
      ]
      content.push dom 'br'
    dom 'fieldset', content

Intro = component
  render: ->
    dom 'div', { class: 'container' }, [
      dom 'h1', "Tom and Havi's Wedding"
      dom 'p', "This is an invite for Mr MacGoo and Partner"
      dom 'p', "Please RSVP before 20th June 2015"
      dom 'form', [
        NamesList()
        Checkboxes
          text: 'Options'
          checkboxes: [
            { name: 'option', value: 1, text: 'Thingy' }
            { name: 'option', value: 2, text: 'Dogs' }
          ]
      ]
    ]

module.exports = component
  render: (props, state) ->
    dom 'div', [
      Intro()
    ]