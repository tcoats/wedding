cycle = (cb) ->
  prev = null
  handle = null
  step = (t) ->
    if prev is null
      prev = t
      return handle = window.requestAnimationFrame step
    dt = t - prev
    prev = t
    cb dt
    handle = window.requestAnimationFrame step
  handle = window.requestAnimationFrame step
  fin: ->
    window.cancelAnimationFrame handle
    window.__loadinghandle = null
    document
      .querySelector '.loading'
      .remove()

width = 150
height = 50
divisions = 15
padding = 3

pos = (offset, index) ->
  "#{padding + index * (width - padding * 2) / divisions} #{height / 2 + (height / 2 - padding) * Math.sin(offset + 10 * index / divisions / Math.PI)}"

calc = (offset) ->
  d = "M#{pos offset, 0}"
  for index in [1..divisions]
    d += "L#{pos offset, index}"
  d

path = document.querySelector '.loading path'
state = 0
window.__loadinghandle = cycle (dt) ->
  state += dt / 500
  path.setAttribute 'd', calc state

setTimeout (->
  return if !window.__loadinghandle?
  svg = document.querySelector '.loading .svg'
  svg.remove()
  timeout = document.querySelector '.loading .timeout'
  timeout.style.display = 'block'
), 10000