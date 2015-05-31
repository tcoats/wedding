setTimeout (->
  timeout = document.querySelector '#loading'
  return unless timeout?
  timeout.style.display = 'block'
), 10000