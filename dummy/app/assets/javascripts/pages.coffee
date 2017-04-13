Pinkman.controller 'index', (c) ->

  c.main = ->
    console.log 'Pinkman controller up & running'

    a = new PinkmanObject
    $('input').attr('data-pinkey',a.pinkey)

  c.action 'paragraph', 'click', (j) ->
    console.log 'You clicked!'
    console.log "content: #{j.html()}"

  c.bind 'test', (obj) ->
    console.log obj.test
  
  c.bind 'uhu', (obj) ->
    console.log obj.uhu

  c.action 'callMeLater', 'click', ->
    'You finally called me!'

  c.bottom ->
    console.log 'sleep'
    sleep 2, ->
      c.endBottom()
      console.log 'wakeup'

Pinkman.controller 'another', (c) ->  
  c.action('another-paragraph', 'click').mirror('index','paragraph')

