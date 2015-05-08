{ component, dom, widget } = require 'odojs'
inject = require 'injectinto'
ql = require 'odoql/ql'
hub = require 'odo-hub'
form2js = require '../plumbing/form2js'
emblem = require './emblem'

rsvp = component render: (state, params) ->
  return dom 'span' if !state?
  
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
          autocapitalize: 'words'
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
      dom 'input',
        attributes: checkboxattrs
        onchange: (e) ->
          hub.emit '{eventid} RSVP {attending}',
            eventid: params.eventid
            attending: e.target.checked
      dom 'span'
      dom 'span', params.eventtitle
    ]
  ]
  whoattrs = class: 'attending'
  if not state.going
    whoattrs.style = 'display: none;'
  
  contents.push dom 'div', attributes: whoattrs, [
    dom 'h3', 'Who is attending?'
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
      emblem()
      dom 'h1', state.invite.to
      
      dom 'p', { attributes: class: 'large' }, [
        'You are invited to the Wedding of '
        dom 'br'
        'Thomas Coats & Harvinder Kaur'
      ]
      
      if state.invite['prewedding']?
        dom 'div', [
          dom 'h2', 'Maiyan'
          dom 'pre', ['10am - 10pm\nFriday 2nd October\nBow Street Studio Apartments']
          dom 'p', 'The Punjabi wedding preparation ceremonies are known as Maiyan. We will be performing Vatna, Mehndi, Jaggo and Choora. Sangeet, Giddha and Bhangra will be present throughout the day - singing and dancing.'
          dom 'p', [
            'Everyone celebrates differently, some of these ceremonies are '
            dom 'a', { attributes: href: 'http://en.wikipedia.org/wiki/Punjabi_wedding_traditions'}, 'described in more detail on wikipedia'
            '.'
          ]
          dom 'p', 'Vatna the bride and groom are washed with turmeric, mustard oil and chick pea flour.'
          dom 'p', 'Mehndi, also known as Henna, is a paste used to draw designs on the skin.'
          dom 'p', 'Jaggo is celebration dancing and loud noises to invite the neighbours to the wedding.'
          dom 'p', 'Choora are bangles worn by the bride.'
          dom 'ul', [
            dom 'li', 'We would appreciate if everyone coming contributed a plate to the lunch or dinner.'
            dom 'li', 'No alcohol will be present during these ceremonies.'
          ]
        ]
      else
        dom 'span'
      
      if state.invite['ceremony']?
        dom 'div', [
          dom 'h2', 'Anand Karaj'
          dom 'pre', '8:30am - 1pm\nSaturday 3rd October\nTe Rapa Sikh Gurdwara'
          dom 'p', 'Anand Karaj literally translates as "Blissful Union" and is the Sikh marriage ceremony in which two individuals are joined in an equal partnership. A Sikh wedding involves greetings, breakfast, the ceremony, lunch and farewell.'
          dom 'p', 'Milni the bride’s side act as hosts and welcome the groom’s side to the temple and to the wedding. The bride herself remains in a back room of the temple until the beginning of the ceremony.'
          dom 'p', 'Breakfast is then served to the arriving guests.'
          dom 'p', 'During the ceremony men sit on one side of the temple hall and women on the other side. The groom takes his place in front of Sri Guru Granth Sahib, the Sikh holy text. The bride joins him.'
          dom 'p', 'The ceremony starts with Ardās, a Sikh prayer said before and after events. At various time during the ceremony everyone will be called to stand and sit.'
          dom 'p', 'The father of the bride then places one end of a scarf or sash worn by the groom over his shoulders in his daughters hand signifying that she is now leaving his care to join her husbands.'
          dom 'p', 'The Lavan hymn of Guru Ram Das is then recited in four stanzas. At the end of each stanza the groom and bride walk clockwise around Sri Guru Granth Sahib. The Lavan hymn describes the progression of love between a husband and wife which is analogous to that between the soul (bride) and God (the husband).'
          dom 'p', 'The Anand hymn by Guru Amar Das is then recited. During the start and the end of the ceremony Kirtan is practiced. This involves chanting with a musical accompaniment.'
          dom 'p', 'Hukamnama. Sri Guru Granth Sahib is opened to any page at random and the hymn is read out as the days order from the Guru for the occasion.'
          dom 'p', 'Karah Prashad the ceremonial sacramental pudding is given to everyone to mark the end of the ceremony.'
          dom 'p', 'The ceremony lasts for about two hours'
          dom 'p', 'Lunch is then served in Langar.'
          dom 'p', 'At around 1pm the Bride and Groom are sent off in Dholi.'

          dom 'ul', [
            dom 'li', 'The temple is a holy place'
            dom 'li', 'Decent knee length or full length dresses or pants for women'
            dom 'li', 'Men wear full length pants'
            dom 'li', 'Heads to be covered at all times in temple with either a scarf or a bandana'
            dom 'li', 'No smoking or drinking alcohol on temple premises'
            dom 'li', 'No tobacco in pockets, please leave in car'
            dom 'li', 'No drinking beforehand'
          ]
        ]
      else
        dom 'span'
      
      if state.invite['reception']?
        dom 'div', [
          dom 'h2', 'Wedding Reception'
          dom 'pre', '5pm - Late\nSaturday 3rd October\nBow Street Studio Apartments'
        ]
      else
        dom 'span'

      if state.invite['breakfast']?
        dom 'div', [
          dom 'h2', 'Breakfast with Newlyweds'
          dom 'pre', '10am\nSunday 4th October\nRaglan Roast'
        ]
      
      dom 'hr'
      
      dom 'form', { onsubmit: submit }, [
        rsvp state.invite['prewedding'],
          eventid: 'prewedding'
          eventtitle: 'RSVP to Maiyan'
        rsvp state.invite['ceremony'],
          eventid: 'ceremony'
          eventtitle: 'RSVP to Anand Karaj (wedding ceremony)'
        rsvp state.invite['reception'],
          eventid: 'reception'
          eventtitle: 'RSVP to the Wedding Reception'
        rsvp state.invite['breakfast'],
          eventid: 'breakfast'
          eventtitle: 'RSVP to Breakfast'
        dom 'label', { attributes: class: 'comments' }, [
          dom 'span', 'Comments'
          dom 'textarea'
        ]
        dom 'button', { attributes: type: 'submit' }, 'Save RSVP'
      ]
    ]