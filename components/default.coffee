{ component, dom, widget } = require 'odojs'
inject = require 'injectinto'
ql = require 'odoql/ql'
hub = require 'odo-hub'
form2js = require '../plumbing/form2js'
emblem = require './emblem'
extend = require 'extend'

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
    invite: ql.query 'invites', params.page.code
  render: (state, params) ->
    if !state.invite?
      setTimeout(->
        hub.emit 'event error, {code} not found', params.page
      , 20)
      return dom 'div'
    submit = (e) ->
      e.preventDefault()
      data = form2js e.target, null, no
      data = extend {}, {to: state.invite.to}, data
      hub.emit 'event code {code} submitted',
        code: params.page.code
        data: data
      no
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
          dom 'p', 'Thomas and Harvinder have chosen to celebrate their wedding over two days to include the Punjabi wedding traditions.'
        ]
      else
        dom 'div', [
          dom 'p', 'Thomas and Harvinder have chosen to follow a traditional Punjabi wedding ceremony.'
        ]
      
      if state.invite['prewedding']?
        dom 'div', [
          dom 'h2', 'Maiyan'
          dom 'p', [
            '10am - 10pm'
            dom 'br'
            'Friday 2nd October'
            dom 'br'
            dom 'a', { attributes: href: 'https://www.google.co.nz/maps/place/Bow+Street+Studios/@-37.799761,174.867363,17z/data=!3m1!4b1!4m2!3m1!1s0x6d12d41762787c37:0xdaa5f7641ec6868c'}, 'Bow Street Studios'
          ]
          dom 'p', 'The Punjabi wedding preparation ceremonies are known as Maiyan. We will be performing Vatna, Mehndi, Jaggo and Choora. Sangeet, Giddha and Bhangra will be present throughout the day - singing and dancing.'
          dom 'p', [
            'Everyone celebrates differently, some of these ceremonies are '
            dom 'a', { attributes: href: 'http://en.wikipedia.org/wiki/Punjabi_wedding_traditions'}, 'described in more detail on wikipedia'
            '.'
          ]
          dom 'p', 'Vatna the bride and groom are washed with turmeric, mustard oil and chick pea flour.'
          dom 'p', 'Mehndi, also known as Henna, is a paste used to draw designs on the skin.'
          dom 'p', 'Jaggo is celebration dancing and loud noises to invite the neighbours to the wedding (symbolically, not literally).'
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
          dom 'p', [
            '8:30am - 1pm'
            dom 'br'
            'Saturday 3rd October'
            dom 'br'
            dom 'a', { attributes: href: 'https://www.google.co.nz/maps/place/New+Zealand+Sikh+Society+Hamilton/@-37.71328,175.211584,17z/data=!3m1!4b1!4m2!3m1!1s0x6d6d23350d4539e1:0x16a1c12e4ab4036a'}, 'Te Rapa Sikh Gurdwara'
          ]
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
          dom 'p', [
            '5pm - Late'
            dom 'br'
            'Saturday 3rd October'
            dom 'br'
            dom 'a', { attributes: href: 'https://www.google.co.nz/maps/place/Bow+Street+Studios/@-37.799761,174.867363,17z/data=!3m1!4b1!4m2!3m1!1s0x6d12d41762787c37:0xdaa5f7641ec6868c'}, 'Bow Street Studios'
          ]
          dom 'p', 'Dinner and drinks with the happy couple.'
        ]
      else
        dom 'span'

      if state.invite['breakfast']?
        dom 'div', [
          dom 'h2', 'Breakfast with Newlyweds'
          dom 'p', [
            '10am'
            dom 'br'
            'Sunday 4th October'
            dom 'br'
            dom 'a', { attributes: href: 'https://www.google.co.nz/maps/place/Raglan+Roast/@-37.800179,174.868397,17z/data=!3m1!4b1!4m2!3m1!1s0x6d12d4176d6a36f9:0x3a3e2a740ee1d2a5'}, 'Raglan Roast'
          ]
          dom 'p', 'We invite anyone staying in Raglan to join us for our morning breakfast and to say our goodbyes before we depart.'
        ]
      
      if state.invite['breakfast']? or state.invite['prewedding']?
        dom 'div', [
          dom 'h2', 'Accomodation'
          dom 'p', 'There are several places to stay in and around Raglan.'
          
          dom 'a', { attributes: href: 'http://www.raglansunsetmotel.co.nz/' }, 'Raglan Sunset Motel'
          dom 'p', 'Raglan Sunset Motel features 24 units offering a range of accommodation, studio units, Family Studios for up to 5 people an Executive unit and a 2 Bedroom self contained apartment for up to 8 people.'
          
          dom 'a', { attributes: href: 'https://www.facebook.com/raglanpalm' }, 'Raglan Palm Beach Motel'
          dom 'p', 'Family and single motel units. Canoes and kayaks available.'
          
          dom 'a', { attributes: href: 'http://www.raglanholidaypark.co.nz/' }, 'Raglan Kopua Holiday Park'
          dom 'p', 'Raglan Kopua Holiday Park offers tent, campervan or caravan, backpacker, cabin and motel units.'
          
          dom 'a', { attributes: href: 'http://www.hiddenvalleyraglan.com/' }, 'Hidden Valley Luxury Retreat'
          dom 'p', 'Two studio rooms each with private spa and Tree Tops Spa Chalet – our most private and luxurious accommodation.'
          
          dom 'a', { attributes: href: 'http://raglanfarmstay.com/' }, 'Raglan Farmstay'
          dom 'p', 'Rooms in the old Farmhouse are available along with two new wood lined cabins. Also available is a sleep out with five beds.'
          
          dom 'a', { attributes: href: 'http://www.raglan.net.nz/2009/10/harbour-view-hotel/' }, 'Harbour View Hotel'
          dom 'p', 'The hotel boasts 3 double rooms, 3 twin, 1 single and 2 family rooms (one sleeping up to 5 and the other up to 4).'
          
          dom 'a', { attributes: href: 'http://www.oceanviewraglan.com/' }, 'Ocean View Raglan'
          dom 'p', 'Bed and Breakfast. There are several rooms available with either king single, queen or king beds to suit whatever your needs.'
          
          dom 'a', { attributes: href: 'http://www.solscape.co.nz/' }, 'Solscape'
          dom 'p', 'Eco accomodation. Stay in self contained cottages, recycled railway cabooses, earth domes or a Tipi Forest.'
        ]
      
      dom 'div', [
        dom 'h2', 'Notes'
        dom 'p', 'A wedding gift is not required but gratefully received.'
        dom 'p', 'We have been living together for more than six years and have an established house full of furniture and appliances. Instead of a material gift we would very much appreciate a contribution to our honeymoon.'
        dom 'p', 'Sponsoring part of our holiday will help us celebrate your contribution. We can think of you at that time.'
        dom 'p', 'Here are some ideas for sponsoring.'
        dom 'ol', [
          dom 'li', 'A roadside snack'
          dom 'li', 'A meal together'
          dom 'li', 'An activity during the day'
          dom 'li', 'Accomodation for one night'
          dom 'li', 'A short flight to a neighbouring area'
          dom 'li', 'A flight to a distant land'
        ]
        dom 'p', 'If you decide to sponsor part of our honeymoon, thank you! And please let us know so we can think of you.'
        dom 'div', { attributes: class: 'grid grid--top' }, [
          dom 'div', [
            dom 'h4', 'International:'
            dom 'strong', 'Our details:'
            dom 'br'
            'T P Coats, K Harvinder'
            dom 'br'
            '3 Sandes Street,'
            dom 'br'
            'Ohaupo 3803'
            dom 'br'
            dom 'br'
            dom 'strong', 'Bank details:'
            dom 'br'
            'Citibank N.A, 23 Customs St, Auckland, New Zealand'
            dom 'br'
            dom 'strong', 'SWIFT code:'
            dom 'span', ' CITINZ2X'
            dom 'br'
            'Your full name and street address is needed (not PO Box)'
            dom 'br'
            '38-9004-0745246-01'
          ]
          dom 'div', [
            dom 'h4', 'Within New Zealand:'
            'T P Coats, K Harvinder'
            dom 'br'
            'Kiwibank'
            dom 'br'
            '38-9004-0745246-01'
          ]
        ]
      ]
      
      dom 'hr'
      
      dom 'h2', 'RSVP'
      
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
          dom 'textarea', { value: state.invite.comments, attributes: name: 'comments' }
        ]
        dom 'button', { attributes: type: 'submit' }, 'Save RSVP'
        if params.success
          dom 'div', 'Thank you, this RSVP has been saved. If you need to update any details just revisit this page and click save again.'
      ]
    ]