# Yo!
# This is a nice overview of Pinkman Controllers.
# If you have the time, read it. :)
# Cheers,
# Unfair (Agilso),
# Pinkman.js creator.

# ------ Global Controller

# Yo! This is a global controller :)
# It runs once the document is ready.
App.ready ->
  console.log "Yo World from Pinkman.js!"

# You can use it as many times as you want.
App.ready ->
  console.log "Let's party rock! ;)"
  console.log 'Find me in:'
  console.log 'assets/javascripts/pinkman/app/controllers/hello.coffee'


# ------ Pinkman Controllers

# A Pinkman Controller looks a lot like a Rails Controller/Action.

# You get data and other complicated stuff from the models
# so you can render them with a view after that.

# This is the 'pinkman-hello' controller
App.controller 'pinkman-hello', ->

  # It will be in effect in every page that
  # has a html element with the 'pinkman-hello' id.

  # The main function gets called everytime the controller initiates.
  @main = ->

    console.log "I am the Pinkman Hello controller!"

    # ... your code ...

    # Here you could load things from db, etc.

    # ... your code ...

    # This is the render function
    # You can use it like this
    # @render
    #   template: 'template-id'
    #   target:   'element-target-id'
    #   object:   anyJsObject

    # Or like this

    # @render 'pinkman-hello'

    # This last form is equivalent to
    # @render
    #   template: 'pinkman-hello-template'
    #   target: 'pinkman-hello'

    # A PinkmanObject is just a like a javascript object. But it's packed with a few more functionalities.

    obj = new AppObject(title: 'Yo!', hint: 'You saw me here')

    # Every Pinkman Object and Collection has a own render function.
    # And it works like @render function.
    obj.render('pinkman-hello')

    # Pinkman binds every attribute in the template with the 'obj' object.
    # So if you change them later... the template gets updated automatically.
    # As long as you use the 'set' function.

    # After 5 seconds, update the title
    $p.sleep 5, ->
      obj.set('title','Up & Running')

    # Don't be scared of $p. It's just an alias of the Pinkman global variable.
    # It has a few helper functions in it. Like the sleep function.

    # Just one more thing about rendering.
    # If a lot of things in 'obj' change, you can call "obj.render()" without any arguments. This will get this object to render itself again.
    # obj.render()


  # ------ Pinkman Actions

  # Pinkman Controller also have actions.
  # Pinkman Actions are associated to JS events.
  # An action has the power to create a event listener and respond to it later, when it gets triggered.
  # And its magic is that it always remember who is the object associated with the action and the dom element that triggered it.

  @action 'you-are-over-me', 'mouseenter', (guessWhoIAm,jQueryEl) ->
    console.log "Who am I? I have a hint: #{guessWhoIAm.hint}"
    jQueryEl.html('Get off')

  @action 'you-are-over-me', 'mouseleave', (obj,j) ->
    j.html('Come here')
