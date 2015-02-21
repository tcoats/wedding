bind = ->
  (string, payload) ->
    return string if !payload?
    string.replace /{([^{}]+)}/g, (original, key) ->
      return original if !payload[key]?
      payload[key]

if define?
  define [], bind
else if module?
  module.exports = bind()
else
  window.template = bind()