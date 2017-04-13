# --- Controller --- #
# Desc: Make pinkman objects and collections react to events. 

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

          # p.drop = (action,on, 'click', (obj,j,ev) ->
          #       options.click(obj,j,ev) if options.click? and typeof options.click == 'function'
          #     p.action action, 'dragenter', (obj,j,ev) ->
          #       options.enter(obj,j,ev) if options.enter? and typeof options.enter == 'function'
          #     p.action action, 'dragover', (obj,j,ev) ->
          #       options.over(obj,j,ev) if options.over? and typeof options.over == 'function'
          #     p.action action, 'dragleave', (obj,j,ev) ->
          #       options.leave(obj,j,ev if options.leave? and typeof options.leave == 'function')
          #     p.action action, 'drop', (obj,j,ev) ->
          #       options.drop(obj,j,ev) if options.drop? and typeof options.drop == 'function'
          #       options.files(obj,ev.originalEvent.dataTransfer.files) if options.files? and typeof options.files == 'function'



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
        pinkey = $(this).data('pinkey') if $(this).is('[data-pinkey]')
        if pinkey?
          obj = Pinkman.get(pinkey)
          action.call(obj,$(this),ev)
        else
          action.call($(this),ev)

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



# # ##########################
  
  
# #   @isViewActive = (id) ->
# #     Pinkman.activeViews.getBy('id',id)?

# #   @getView: (id) ->
# #     views = new PinkmanCollection
# #     Pinkman.activeViews.each (view) ->
# #       views.push(view) if view.id == id
# #     views.call = (opts) ->
# #       if opts? and typeof opts == 'object' and opts.action? and opts.args?
# #         @each (v) ->
# #           v.actions.each (action) ->
# #             action.callback(opts.args...) if action.action == opts.action
# #     return(views)

# #   # Pinkman manipulates templates through View.
# #   # View is always associated with a controller.
# #   # A controller contains methods (actions) which responds to js events.
# #   @view = (id,controller) ->
# #     if controller?
# #       $(document).ready ->

# #         selector = Pinkman.helper.createSelector(id)
        
# #         if $(selector).length
          
# #           view = new PinkmanObject
# #           view.set('id',id)
# #           view.actions = new PinkmanCollection
# #           view.set('selector',selector)

# #           p = new Object

# #           view.set('view',p)
# #           window.Pinkman.activeViews.push(view) unless window.Pinkman.activeViews.getBy('selector',view.selector)?

# #           p.executeAction = (action,eventName,callback) ->
# #             $("body").on eventName, "##{id} [data-action='#{action}']", (ev) ->
# #               # console.log "execute action => in view: #{id} => call action: #{action} => on: #{eventName}"
# #               ev.preventDefault() unless eventName == 'keypress'
# #               pinkey = $(this).data("pinkey") if $(this).is("[data-pinkey]")
# #               obj = PinkmanGlue.all[pinkey]
# #               callback(obj,$(this),ev)


# #           p.action = (action,eventName,callback) ->
# #             a = new PinkmanObject
# #             a.assign action: action, eventName: eventName, callback: callback
# #             view.actions.push a
# #             # console.log "define action => in view: #{id} => call action: #{action} => on: #{eventName}"
# #             if typeof eventName == "string"
# #               @executeAction(action,eventName,callback)
# #             else if eventName instanceof Array
# #               @executeAction(action,e,callback) for e in eventName

# #           p.trigger = (action,eventName,options...) ->
# #             a = view.actions.getByAttributes
# #               action: action
# #               eventName: eventName
# #             a.callback(options...) if a?

# #           p.endOfPage = (callback) ->      
# #             setTimeout ->        
# #               window.lastEndOfPage = 0
# #               $(window).scroll ->
# #                 t = Date.now()
# #                 # console.log 'altura'
# #                 # console.log ($(document).height() - $(window).scrollTop() - document.body.offsetHeight < 800)
# #                 # console.log 'tempo'
# #                 # console.log (window.lastEndOfPage < t)
# #                 # console.log 'endOfPageRunning'
# #                 # console.log window.endOfPageRunning
# #                 if ((($(document).height() - $(window).scrollTop() - document.body.offsetHeight < 800) and (window.lastEndOfPage) < t) or ($(document).height() - $(window).scrollTop() - document.body.offsetHeight == 0)) and not window.endOfPageRunning
# #                   window.endOfPageRunning = true
# #                   # console.log 'triggou end of page'
# #                   window.lastEndOfPage = t
# #                   callback()
# #             , 200

# #           p.finishEndOfPage = () ->
# #             window.endOfPageRunning = false

# #           constructObjFromArray = (obj,array,i=0) ->
# #             obj = new Object unless typeof obj=='object'
# #             if i < array.length
# #               obj[array[i]] = constructObjFromArray(obj[array[i]],array,i+1)
# #               return obj
# #             else
# #               return(new Object)

# #           p.bindAll = ->
# #             Pinkman.callOnce ->
# #               array = []
# #               $(selector).find("[name]").each (i,el) ->
# #                 array.push($(el).attr('name')) if array.indexOf($(el).attr('name')) == -1
              
# #               p.bind(name) for name in array
# #               # console.log array

# #           p.bind = (attrs...) ->
# #             callback = attrs.pop() if typeof attrs[attrs.length-1]=='function'
# #             mainAttr = attrs.pop()
# #             @action mainAttr,['keyup','change'], (obj,jquery) ->
# #               # console.log obj
# #               Pinkman.callOnce ->
# #                 # console.log 'chamou bind once'
# #                 obj.assign  constructObjFromArray(obj,attrs)
# #               aux = obj
# #               aux = aux[attr] for attr in attrs
# #               if aux[mainAttr] != jquery.val()             
# #                 if aux.isPink 
# #                   aux.set(mainAttr,jquery.val())
# #                 else
# #                   aux[mainAttr] = jquery.val()
# #                 callback(obj,jquery) if callback? and typeof callback == 'function'

# #           # drop
# #           ## -- usage: 
# #           ## v.drop 'action', 
# #           ##   enter: callback(obj,jquery,event)  -  when user dragging enters 'action'
# #           ##   over: callback(obj,jquery,event)   -  when user dragging is over 'action'
# #           ##   leave: callback(obj,jquery,event)  -  when user dragging leaves 'action'
# #           ##   drop: callback(obj,jquery,event)   -  when user drops something in 'action'
# #           ##   files: callback(obj,files)         -  captures whatever user droped in 'action'

# #           p.drop = (action,options) ->
# #               p.action action, 'click', (obj,j,ev) ->
# #                 options.click(obj,j,ev) if options.click? and typeof options.click == 'function'
# #               p.action action, 'dragenter', (obj,j,ev) ->
# #                 options.enter(obj,j,ev) if options.enter? and typeof options.enter == 'function'
# #               p.action action, 'dragover', (obj,j,ev) ->
# #                 options.over(obj,j,ev) if options.over? and typeof options.over == 'function'
# #               p.action action, 'dragleave', (obj,j,ev) ->
# #                 options.leave(obj,j,ev if options.leave? and typeof options.leave == 'function')
# #               p.action action, 'drop', (obj,j,ev) ->
# #                 options.drop(obj,j,ev) if options.drop? and typeof options.drop == 'function'
# #                 options.files(obj,ev.originalEvent.dataTransfer.files) if options.files? and typeof options.files == 'function'

# #           # autcomplete feature
# #           # description - search through a certain collection, display a list and callback when the user selected someone from the list.

# #           # usage: p.autocomplete(object)

# #           # object.attribute: attribute from the object who generated the form that is going to be autocompleted
# #           # object.with: a collection that is going to be searched/filtered
# #           # object.display: what attribute from the collection that is going to be displayed in the list
# #           # object.filter: name of the function or function to filter the collection according to what user is typing
# #           # object.callback: what to do after user select someone from the list

# #           p.autocomplete = (options) ->
# #             window.options = options
# #             if options? and typeof options == 'object'
# #               options.filter = 'search' unless options.filter?
# #               options.display = 'name' unless options.display?

# #               @action "autocomplete-for-#{options.attribute}", 'click', (selected,j) ->
# #                 if options.callback? and typeof options.callback == 'function'
# #                   options.callback(selected.autocomplete.origin,selected,j) 

# #                   # keep form focus in the right place
# #                   formAttributes = $("[data-pinkey='#{selected.autocomplete.origin.pinkey}'][name]")
# #                   thisAttribute = formAttributes.closest("[name='#{options.attribute}']")
# #                   nextAttribute = formAttributes[formAttributes.index(thisAttribute)+1]
# #                   nextAttribute.focus() if nextAttribute?

# #               @bind options.attribute, (o,j) =>
# #                 NProgress.start()
# #                 clearTimeout(window.pinkmanAutocompleteBinding)
# #                 doAfter 8, ->
# #                   query = o[options.attribute]
# #                   j.parent().find('.autocomplete').show()
# #                   if query? and query != ''
# #                     setupAndRender = (c) ->
# #                       c.makeIndex()
# #                       c.each (obj) ->
# #                         obj.set('autocomplete', {origin: o,attribute: options.attribute})
# #                         if typeof options.display == 'function' then obj.set('display',options.display(obj)) else obj.set('display',obj[options.display]) 
# #                       c.render
# #                         template: 'autocomplete-template'
# #                         target: "autocomplete-#{options.attribute}-#{o.pinkey}"
# #                       NProgress.done()

# #                     if options.filter? and typeof options.filter == 'function'
# #                       options.filter options.with,query, (c) ->
# #                         setupAndRender(c)
# #                     else
# #                       c = options.with
# #                       c[options.filter] query, (c) ->
# #                         setupAndRender(c)
# #                   else
# #                     j.parent().find('.autocomplete').hide()
# #                     NProgress.done()

# #                 , 'pinkmanAutocompleteBinding'

# #           controller(p)

# #           p.main() if p.main? and typeof p.main == 'function'
# #     else
# #       @getView(id)

# #   # same as view but can only be open/defined once.
# #   @uniqView: (id,controller) ->
# #     @view(id,controller) unless Pinkman.isViewActive(id)

# #   @popstate: () ->
# #     if window? and history? and history.pushState?
# #       unless @popstateActivated
# #         @popstateActivated = true
# #         window.onpopstate = (event) ->
# #           Pinkman.get(event.state.pinkey).reRender()

# # $(document).ready ->
# #   unless Pinkman.pathname?
# #     Pinkman.pathname = window.location.pathname
# #     Pinkman.pathname = Pinkman.pathname + '/' if Pinkman.pathname.charAt([Pinkman.pathname.length] - 1) != "/"