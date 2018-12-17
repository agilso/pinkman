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
    # console.log params
    @params = new Object
      
    (@params[k] = v) for k,v of params if params? and typeof params == 'object'
    @params
  
  title: (title) ->
    $('title').html(title) if Pinkman.isString(title)
    
  # build a controller from user definition
  # main: boolean argument that forces main function be executed
  build: (main,routeMatcher) ->
    if @builder? and typeof @builder == 'function'
      @builder(this)
      if @_layout and @isSummoned(main)
        @_layout = @_layout + '-layout' unless /-layout$/.test(@_layout)
        $p.render
          template: @_layout
          callback: (obj,content) ->
            $('body').html(content)
            routeMatcher.makeYielder() if routeMatcher?
      else
        routeMatcher.makeYielder() if routeMatcher?
      @main() if @isSummoned(main)
      return(true)
    else
      return(false)
  
  isSummoned: (main) ->
    @main? and (main or ($("##{@id}").length and typeof @main == 'function'))
  
  layout: (layoutName) ->
    @_layout = layoutName
    
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
      
  
  esc: (callback) ->
    PinkmanAction.define
      id: 'esc'
      eventName: 'keyup'
      controller: this
      selector: "##{this.id}"
      callback: (obj, j, ev) ->
        # console.log ev
        callback() if ev.keyCode == 27


  # bindAll works by attaching a 'change' event handler to all [data-action] inside a form.
  # but... in a few ocasions, the developer must have the capability to exclude certain attributes from this binding.
  # thats when the "except" option comes in
  # maybe a "only" option is going to be implemented in the near future
  bindAllSelector: (id, options) ->
    except = options.except if $p.isObject(options) and options.except?
    selector = "##{@id} form [data-action], ##{@id} .form [data-action]"
    
    # except handler
    if except
      throw 'Pinkman bindAll: except option should be a string or an array' if not $p.isString(except) and not $p.isArray(except)
      except = [except] if $p.isString(except)
      exceptionsArray = []
      for excep in except
        exceptionsArray.push "[data-action='#{excep}']"
      selector = selector.replace(/\[data-action\]/g,"[data-action]:not(#{exceptionsArray.join(',')})")
    
    # debugger
    # console.log selector
    
    # return selector
    selector
      
  
  bindAll: (args...) ->
    if args.length == 1
      if $p.isFunction(args[0])
        callback = args[0]
      else if $p.isObject(args[0])
        options = args[0]
    else if args.length == 2
      callback = args.pop()
      options = args.shift()
      
    PinkmanAction.define
      id: "#{@pinkey}-bindAll"
      selector: @bindAllSelector(@id, options)
      eventName: ['change','keyup']
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
    # modifiquei recentemente, verificar se houver atribuições duplas, etc
    # if $("##{@id}").length
    # console.log "bindou: #{attribute}, #{callback}"
    
    @action attribute, ['keyup','change'], (obj,$j,args...) ->
      # console.log obj[attribute]
      # console.log $j.val()
      if obj[attribute] != $j.val()             
        # console.log 'trocou de valor'
        obj.set(attribute,$j.val()) 
        callback(obj,$j,args...) if callback? and typeof callback == 'function'
      # else
      #   console.log 'mesmo valor'
      
      
  # === Autocomplete ===

  # -- Usage: autocomplete(input_name,options)

  # -- Overview
  # 1: User types something
  # 2: Pinkman searchs through a collection and then renders the result
  # 3: User selects a record
  # 4: Pinkman sends the selected record to callback function

  # -- Parameters & Options
  # @autocomplete(attribute,options)
  # options:
    # with: [collection] 
    # pinkman collection responsible for filtering/searching the results
    
    # method: [search|yourCustomMethod] 
    # Search is the default. Anythings that filters by a 'query'.
    # You can define a yourCustomMethod inside the collection model like this:
    # yourCustomMethod: (user_query, callback) ->
      # -- perform a selection based on user_query
      # callback(this) if $p.isFunction(callback)
    
    # template: [template-id] (optional)
    # Any template that has a 'select-attribute' action
    # If you don't specify a template, Pinkman will try "attribute-autocomplete-template" by default
    
    # target: [target-id]
    # Where pinkman should yield results
    # If you don't specify a target, Pinkman will try "attribute-autocomplete" by default
    
    # loading: loading function
    # Run something before searching (you can use it for some loading animation)
    
    # call: callback function. 
    # What to do when user selects something?
  autocomplete: (attr_name, options) ->
    # error handling / verifing args
    throw 'Pinkman Autocomplete: Missing options object' unless $p.isObject(options)
    throw 'Pinkman Autocomplete: Missing "with" collection' unless options.with?
    throw 'Pinkman Autocomplete: Missing "call" callback function' unless $p.isFunction(options.call)
    
    # variables // user options // default options
    collection = options.with
    callback = options.call
    template = if options.template? then options.template else "#{attr_name}-autocomplete"
    target = if options.target? then options.target else "#{attr_name}-autocomplete"
    method = if options.method? then options.method else 'search'
    loading = options.loading if $p.isFunction(options.loading)
    autoHide = if options.autoHide? then options.autoHide else yes
    autoWidth = if options.autoWidth? then options.autoWidth else yes
    wait = if options.wait? then options.wait else 0.75
    waitTimerName = "#{attr_name}AutocompleteTimer"
    
    # hide initially
    $("##{target}").hide() if autoHide
    
    # resize autocomplete
    if autoWidth
      $(window).resize ->
        $("##{target}").width($("input[name='#{attr_name}']").innerWidth() - ($("##{target}").innerWidth() - $("##{target}").width()))
    
    # responding to user typing
    @bind attr_name, (obj,j) ->  
      
      # loading
      loading(obj,j,attr_name) if loading?
      
      # removes autocompleted Class
      j.removeClass('autocompleted')
      
      # wait until user finish typing
      clearTimeout(window[waitTimerName]) if window[waitTimerName]?
      window[waitTimerName] = $p.sleep wait, =>
        
        # calls the filter method (search)
        collection[method] obj[attr_name], (collection) ->
          
          # render results
          collection.render
            template: template
            target: target
            callback: ->
              # Hide or show autocomplete
              if autoHide
                if obj[attr_name]? and obj[attr_name] != ''
                  $("##{target}").fadeIn()
                else
                  $("##{target}").fadeOut()
              
              # Set the autocomplete target width to same as the input
              if autoWidth
                $("##{target}").width($("input[name='#{attr_name}']").innerWidth() - ($("##{target}").innerWidth() - $("##{target}").width()))
    
    # user chooses something and click
    @action "select-#{attr_name}", 'click', (args...) =>
      # console.log "#{@selector()} input[action='#{attr_name}']"
      $input = $("#{@selector()} input[data-action='#{attr_name}']")
      $input.addClass('autocompleted')
      obj = Pinkman.get($input.data('pinkey'))
      $("##{target}").fadeOut() if autoHide
      callback(obj,$input,args...)
      


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
    throw 'Subscriber: blank options param' unless opt
    throw 'Subscriber: options not a object' unless $p.isObject(opt)
    throw 'Subscriber: options missing room value' unless opt.room?
    throw 'Subscriber: options missing scope value' unless opt.scope?
    params = if (typeof opt == 'object' and opt['params']?) then opt['params'] else new Object
    params.channel = channel
    if $p.isObject(opt)
      params.room = opt.room
      params.scope = opt.scope
      params.filter_by = (opt.filter_by or opt.filterBy ) if (opt.filterBy? or opt.filter_by?)
    Pinkman.cable.subscriptions.create params, received: callback
    
  scrolling: (callback) -> 
    $(document).on 'scroll', =>
      if $(@selector()).length
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
    $(document).off('scroll')
      
# --- actions object
class window.PinkmanAction extends window.PinkmanObject
  
  constructor: (args...) ->
    @_event_listening = new Object
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
      # a.log 'eventName'
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
    @_event_listening = new Object
    for ev in @events
      $('body').off ev, @selector
    
  # Desc: attaches one single event
  attach: (eventName) ->
    if Pinkman.isString(eventName) and not @_event_listening[eventName]
      action = this
      action._event_listening[eventName] = yes
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