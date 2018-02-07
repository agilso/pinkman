Pinkman.bottomDistance = 800

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
  
  clear: ->
    @actions.each (a) ->
      a.clear()

  render: (args...) ->
    Pinkman.render(args...)

  constructor: (args...) ->
    @actions = new PinkmanActions
    super(args...)
    
  selector: ->
    '#' + @id

  setParams: (params) ->
    query = location.search.substring(1);
    if query? and query!=''
      @params = JSON.parse('{"' + decodeURI(query).replace(/"/g, '\\"').replace(/&/g, '","').replace(/=/g,'":"') + '"}')
    else
      @params = new Object
      
    (@params[k] = v) for k,v of params if params? and typeof params == 'object'
    @params
  
  title: (title) ->
    $('title').html(title) if Pinkman.isString(title)
    
  # build a controller from user definition
  # main: boolean argument that forces main function be executed
  build: (main) ->
    if @builder? and typeof @builder == 'function'
      @builder(this)
      @main() if @main? and (main or ($("##{@id}").length and typeof @main == 'function'))
      return(true)
    else
      return(false)

  action: (args...) ->
    if args.length == 1
      @actions.getBy('name',args[0])
    else
      [name, eventName,callback,unknown...] = args
      PinkmanAction.define
        id: "#{@pinkey}-#{name}-#{eventName}"
        name: name
        eventName: eventName
        callback: callback
        controller: this
        selector: "##{this.id} [data-action='#{name}']"
      
  
  # verificar - verify
  # mudei recentemente, pode estar cagado
  esc: (callback) ->
    PinkmanAction.define
      id: 'esc'
      eventName: 'keyup'
      controller: this
      callback: (obj, j, ev) ->
        callback() if ev.keyCode == 27
    

  bindAll: (callback=null) ->
    PinkmanAction.define
      id: "#{@pinkey}-bindAll"
      selector: "##{@id} form [data-action], ##{@id} .form [data-action]"
      eventName: 'change, keyup'
      controller: this
      callback: (obj,$j) ->
        obj.set($j.attr('name'),$j.val()) if obj[$j.attr('name')] != $j.val()
        callback(obj,$j,$j.attr('name')) if typeof callback == 'function'
        
    
  bind: (attribute,callback='') ->
    if Pinkman.isArray(attribute)
      @bindIndividually(attr,callback) for attr in attribute
    else
      @bindIndividually(attribute,callback)

  bindIndividually: (attribute,callback='') ->
    if $("##{@id}").length
      @action attribute, ['keyup','change'], (obj,jquery,args...) ->
        if obj[attribute] != jquery.val()             
          obj.set(attribute,jquery.val()) 
          callback(obj,jquery,args...) if callback? and typeof callback == 'function'

  # bindAll: ->

  bottom: (callback) -> 
    if $("##{@id}").length
      setTimeout ->        
        Pinkman._lastEndOfPage = 0 unless Pinkman._lastEndOfPage?
        $(window).scroll ->
          t = Date.now()
          distanceFromBottom = $(document).height() - $(window).scrollTop() - document.body.offsetHeight
          if ( (distanceFromBottom < Pinkman.bottomDistance and Pinkman._lastEndOfPage < t) or distanceFromBottom == 0 ) and not Pinkman._bottomTriggered
            Pinkman._bottomTriggered = true
            Pinkman._lastEndOfPage = t
            callback()
      , 50

  endBottom: () ->
    Pinkman._bottomTriggered = false
 
 
  subscribe: (channel,opt) ->
    throw 'ActionCable not found.' unless Pinkman.cable?
    throw 'Channel not specificied.'  unless channel? and channel != ''
    try
      callback = if typeof opt == 'function' then opt else opt['callback']
    catch
      throw 'Callback not found.'
    params = if (typeof opt == 'object' and opt['params']?) then opt['params'] else new Object
    params.channel = channel
    Pinkman.cable.subscriptions.create params, received: callback
    
  scrolling: (callback) -> 
    if $("##{@id}").length
      $(window).scroll ->
        unless Pinkman._stopScroll
          Pinkman._stopScroll = yes
          callback(window.scrollY) 

  endScroll: ->
    Pinkman._stopScroll = no

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
      if Pinkman.dragged?
        options.drop(obj, j,Pinkman.dragged.obj, Pinkman.dragged.j,ev) if options.drop? and typeof options.drop == 'function'
      else
        options.drop(obj,j,ev) if options.drop? and typeof options.drop == 'function'
      options.files(obj,ev.originalEvent.dataTransfer.files,j) if options.files? and typeof options.files == 'function'

  drag: (action,options) ->
    @action action, 'mousedown', (obj,j,ev) ->
      j.attr('draggable','true')
      Pinkman.dragged = new Pinkman.object(obj: obj, j: j, ev: ev)
        
  isActive: () ->
    $("##{@id}").length > 0

# --- controller collection
class window.PinkmanControllers extends window.PinkmanCollection
  
  clear: (callback) ->
    @unbindScrolling() if @pinkey == Pinkman.controllers.pinkey
    @each (c) ->
      c.clear()
    , callback
    
  unbindScrolling: ->
    $(window).off('scroll')
      
# --- actions object
class window.PinkmanAction extends window.PinkmanObject
  
  constructor: (args...) ->
    super(args...)
    @call = ->
    @events = []
  
  # helper to define custom actions
  @define: (options) ->
    throw 'Pinkman - Define Action: argument must be a object' unless $p.isObject(options)
    throw 'Pinkman - Define Action: missing id' unless $p.hasAttribute(options,'id')
    throw 'Pinkman - Define Action: missing eventName' unless $p.hasAttribute(options,'eventName')
    throw 'Pinkman - Define Action: missing controller' unless $p.hasAttribute(options,'controller')
    throw 'Pinkman - Define Action: missing selector' unless $p.hasAttribute(options,'selector')
    # throw 'Pinkman - Define Action: missing callback' unless $p.hasAttribute(options,'callback')
    # throw 'Pinkman - Define Action: callback must be a function' unless $p.isFunction('callback')
    options.controller = Pinkman.controller(options.controller) if $p.isString(options.controller)
    if options.controller.actions.empty(id: options.id)
      a = new PinkmanAction
      a.set 'id', options.id
      a.set('name', if options.name then options.name else options.id)
      a.set 'controller', options.controller
      a.set 'selector', options.selector
      a.set 'eventName', options.eventName
      a.set 'call', options.callback if options.callback
      Pinkman.actions.push(a)
      a.controller.actions.push(a)
      a.listen()
      return(a)
    else
      # console.log options.controller
      # console.log options.id
      return(options.controller.actions.getBy('id',options.id))
      
    
      
  # Desc: mirrors/redirects a action to another already defined
  mirror: (controllerID,actionName) ->
    # console.log this
    # gets all actions named 'action' in all controllers with 'controller' id
    actions = new PinkmanActions
    Pinkman.controllers.select(id: controllerID).each (c) ->
      c.actions.select(name: actionName).each (a) ->
        actions.forcePush(a)
    @call = (args...) ->
      actions.call(args...)
    @listen()

  # Desc: mirrors alias
  redirect: (args...) ->
    @mirror(args...)

  # Desc: mirrors alias
  redirectTo: (args...) ->
    @mirror(args...)

  # Desc: removes event
  clear: ->
    @_event_listening = no
    for ev in @events
      $('body').off ev, @selector
    
  # Desc: attaches one single event
  attach: (eventName) ->
    if Pinkman.isString(eventName) and not @_event_listening
      action = this
      action._event_listening = yes
      @events.push(eventName)
      $('body').on eventName, action.selector, (ev) ->
        # debugger
        # console.log "#{action.id}: called - #{action.name}"
        ev.preventDefault() if eventName != 'keypress' and eventName != 'mousedown'
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
  call: (args...) ->
    @each (action) ->
      action.call(args...)

  find: (name,callback) ->
    @select(name: name, callback)

# --- functions

# Desc: instantiates Pinkman.controllers
# place where all active controllers will reside
Pinkman.controllers = new window.PinkmanControllers

# Desc: returns true if a certain view is active, false otherwise.
Pinkman.controllers.isActive = (id) ->
  @find(id)?

Pinkman.controllers.def = (id,builder) ->
  $(document).ready ->
    if id? and builder?
      c = new PinkmanController(id: id, builder: builder)
      Pinkman.controllers.forcePush(c)
      return(c.build())
    else
      return false

Pinkman.controller = (args...) ->
  if args.length == 1
    Pinkman.controllers.find(args[0])
  else
    Pinkman.controllers.def(args...)

Pinkman.actions = new PinkmanActions

$(document).ready ->
  $p.sleep 0.1, ->
    array = []
    Pinkman.actions.each (a) -> 
      array.push(a.selector) if (a.eventName == 'click') or (Pinkman.isArray(a.eventName) and a.eventName.indexOf('click') !=-1)
      
    selector = array.join(', ')
    Pinkman.css(selector, 'cursor', 'pointer !important')