Pinkman.controller 'index', (c) ->

  c.main = ->
    console.log 'Pinkman controller up & running'

    a = new PinkmanObject
    $('input').attr('data-pinkey',a.pinkey)

  c.action 'paragraph', 'click', (obj,j) ->
    if obj?
      console.log 'This paragraph is in the scope of the object below:'
      console.log obj

    console.log 'You clicked!'
    console.log "content: #{j.html()}"

  c.bind 'test', (obj) ->
    console.log obj.test

  c.action 'callMeLater', 'click', ->
    console.log 'You finally called me!'

  c.bottom ->
    console.log 'sleep'
    sleep 2, ->
      c.endBottom()
      console.log 'wakeup'
      c.action('callMeLater').call()

  c.drop 'drop-zone',
    enter: ->
      console.log 'entered'
    leave: ->
      console.log 'left'
    over: ->
      console.log 'hey! get off me!'
    drop: ->
      console.log 'dropou'
    files: (obj,files) ->
      console.log files

Pinkman.controller 'another', (c) ->  
  c.action('another-paragraph', 'click').mirror('index','paragraph')

