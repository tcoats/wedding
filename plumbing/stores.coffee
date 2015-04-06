jsonstore = require 'odoql-json/store'
localstore = require 'odoql-localstorage/store'

get = (url, cb) ->
  http = new XMLHttpRequest()
  http.onreadystatechange = ->
    return if http.readyState isnt XMLHttpRequest.DONE
    if http.status is 200
      return cb null, JSON.parse http.responseText
    cb status: http.status, message: http.responseText
  http.open 'GET', url, true
  http.send()

# Here we define our store method that takes an input query and executes it against the available stores returning state.
stores =
  # now implemented on the server
  #organisations: jsonstore require '../data/organisations'
  localstorage: localstore
  __dynamic: (query, cb) ->
    query = encodeURIComponent JSON.stringify query
    get "/query?q=#{query}", cb

module.exports = stores