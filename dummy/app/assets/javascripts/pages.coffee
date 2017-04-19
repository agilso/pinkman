Pinkman.controller 'index', (c) ->

  c.main = ->
    console.log 'Pinkman controller up & running'

    window.johnny = new PinkmanObject(title: Pinkman.template_engine, deep: {name: 'Johnny Deep! Not Depp'})
    
    johnny.render
      template: 'template'
      target: 'target'

    johnny.render
      template: 'johnny-form'
      target: 'form'
      reRender: no

    johnny.watch()

  c.action 'paragraph', 'click', (obj,j) ->
    console.log "content: #{j.html()}"

  c.bind 'title'

  c.action 'who-is-this','click', (obj,j) ->
    console.log obj.deep

  c.action 'callMeLater', 'click', ->
    console.log 'You finally called me!'

  c.bottom ->
    c.action('callMeLater').call()
    sleep 1, ->
      c.endBottom()

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

