Pinkman.maxSearchLevel = 15

Pinkman.closest = (jquery,level=0) ->
  if jquery.is('[data-pinkey]')
    pinkey = jquery.attr('data-pinkey')
    return(Pinkman.get(pinkey))
  else if level < Pinkman.maxSearchLevel
    Pinkman.closest(jquery.parent(),level+1)
  else
    return(null)

# --- Controller --- #
# Desc: Make pinkman objects respond to events. 

# --- controller object
class window.PinkmanController extends window.PinkmanObject

  constructor: (args...) ->
    @actions = new PinkmanActions
    super(args...)

  # build a controller from user definition
  build: ->
    if @builder? and typeof @builder == 'function'
      @builder(this)
      @main() if @main? and typeof @main == 'function'
      return(true)
    else
      return(false)

  action: (args...) ->
    if args.length == 1
      @actions.getBy('name',args[0])
    else
      [name, eventName,callback,unknown...] = args
      a = new PinkmanAction(name: name, eventName: eventName, call: callback, controller: this)
      @actions.push(a)
      a.listen() if a.call? and typeof a.call == 'function'
      return(a)

  bind: (attribute,callback='') ->
    if Pinkman.isArray(attribute)
      @bindIndividually(attr,callback) for attr in attribute
    else
      @bindIndividually(attribute,callback)

  bindIndividually: (attribute,callback='') ->
    @action attribute, ['keyup','change'], (obj,jquery,args...) ->
      if obj[attribute] != jquery.val()             
        obj.set(attribute,jquery.val()) 
        callback(obj,jquery,args...) if callback? and typeof callback == 'function'

  bindAll: ->

  bottom: (callback) -> 
    setTimeout ->        
      window._pinkman_lastEndOfPage = 0 unless window._pinkman_lastEndOfPage?
      $(window).scroll ->
        t = Date.now()
        distanceFromBottom = $(document).height() - $(window).scrollTop() - document.body.offsetHeight
        if ( (distanceFromBottom < 800 and window._pinkman_lastEndOfPage < t) or distanceFromBottom == 0 ) and not window._pinkman_bottomTriggered
          window._pinkman_bottomTriggered = true
          window._pinkman_lastEndOfPage = t
          callback()
    , 50

  endBottom: () ->
    window._pinkman_bottomTriggered = false
 

  # drop
  ## -- usage: 
  ## v.drop 'action', 
  ##   enter: callback(obj,jquery,event)  -  when user dragging enters 'action'
  ##   over: callback(obj,jquery,event)   -  when user dragging is over 'action'
  ##   leave: callback(obj,jquery,event)  -  when user dragging leaves 'action'
  ##   drop: callback(obj,jquery,event)   -  when user drops something in 'action'
  ##   files: callback(obj,files)         -  captures whatever user droped in 'action'

  drop: (action,options) ->
    @action action, 'click', (obj,j,ev) ->
      options.click(obj,j,ev) if options.click? and typeof options.click == 'function'
    @action action, 'dragenter', (obj,j,ev) ->
      options.enter(obj,j,ev) if options.enter? and typeof options.enter == 'function'
    @action action, 'dragover', (obj,j,ev) ->
      options.over(obj,j,ev) if options.over? and typeof options.over == 'function'
    @action action, 'dragleave', (obj,j,ev) ->
      options.leave(obj,j,ev if options.leave? and typeof options.leave == 'function')
    @action action, 'drop', (obj,j,ev) ->
      options.drop(obj,j,ev) if options.drop? and typeof options.drop == 'function'
      options.files(obj,ev.originalEvent.dataTransfer.files) if options.files? and typeof options.files == 'function'




# --- controller collection
class window.PinkmanControllers extends window.PinkmanCollection

# --- actions object
class window.PinkmanAction extends window.PinkmanObject

  # Desc: mirrors/redirects a action to another already defined
  mirror: (controllerID,actionName) ->
    # gets all actions named 'action' in all controllers with 'controller' id
    actions = new PinkmanActions
    Pinkman.controllers.select(id: controllerID).each (c) ->
      c.actions.select(name: actionName).each (a) ->
        actions.push(a)
    @controller.action @name, @eventName, (args...) ->
      actions.each (action) ->
        action.call(args...)

  # Desc: mirrors alias
  redirect: (args...) ->
    @mirror(args...)

  # Desc: mirrors alias
  redirectTo: (args...) ->
    @mirror(args...)

  # Desc: attaches one single event
  attach: (eventName) ->
    if Pinkman.isString(eventName)
      action = this
      $('body').on eventName, "##{action.controller.id} [data-action='#{action.name}']", (ev) ->
        ev.preventDefault() unless eventName == 'keypress'
        obj = window.Pinkman.closest($(this))
        action.call(obj,$(this),ev)

  # Desc: bind action events
  listen: () ->
    if Pinkman.isString(@eventName)
      @attach(@eventName)
    else if Pinkman.isArray(@eventName)
      @attach(ev) for ev in @eventName
       

# --- action collection
class window.PinkmanActions extends window.PinkmanCollection

# --- functions

# Desc: instantiates Pinkman.controllers
# place where all active controllers will reside
Pinkman.controllers = new window.PinkmanControllers

# Desc: returns true if a certain view is active, false otherwise.
Pinkman.controllers.isActive = (id) ->
  @find(id)?

Pinkman.controllers.def = (id,builder) ->
  $(document).ready ->
    if id? and builder? and ($('#'+id).length > 0)
      c = new PinkmanController(id: id, builder: builder)
      Pinkman.controllers.push(c)
      return(c.build())
    else
      return false

Pinkman.controller = (args...) ->
  if args.length == 1
    Pinkman.controllers.find(args[0])
  else
    Pinkman.controllers.def(args...)