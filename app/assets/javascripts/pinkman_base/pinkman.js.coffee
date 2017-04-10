class window.Pinkman

#   # old

  @collections = []
  @objects = []
  @all = []

  @isNumber: (n) ->
    !isNaN(parseFloat(n)) && isFinite(n)

  @isArray: (array) ->
    array? and array.constructor is Array

#   @get: (id) ->
#     this.all[id]

#   @helper =
#     createSelector: (id) ->
#       if typeof id=='string' 
#         selector = "##{id}" 
#       else if id instanceof Array
#         selector = []
#         selector.push("##{a}") for a in id
#         selector.join(", ")
#       return(selector)

#   @activeViews = new window.PinkmanCollection
  
#   @isViewActive = (id) ->
#     selector = Pinkman.helper.createSelector(id)
#     Pinkman.activeViews.getBy('selector',selector)?

  
#   doAfter = (ds, callback,timer = "do_after_timer") ->
#     window[timer] = window.setTimeout( ->
#       callback() if typeof callback == "function"
#     ,ds*100)
  
#   # Any mustache syntax like will do the job
#   @render = (options) ->
#     if options.template? and $("##{options.template}").length
#       options.object = new Object unless options.object?
#       htmlToRender = if html? then html else $("#" + options.template).html()
#       view = Hogan.compile(htmlToRender,{delimiters: '<< >>'})
#       content = view.render(options.object)
#       $("##{options.target}").html(content) if options.target?
#       options.callback(content) if options.callback? and typeof options.callback == 'function'
#       return content
#     else
#       return false

#   @defineVar: (name,value) ->
#     if value?
#       window[name]= value 
#     else
#       window[name]=''
#     true

#   @getView: (id) ->
#     views = new PinkmanCollection
#     Pinkman.activeViews.each (view) ->
#       views.push(view) if view.id == id
#     views.call = (opts) ->
#       if opts? and typeof opts == 'object' and opts.action? and opts.args?
#         @each (v) ->
#           v.actions.each (action) ->
#             action.callback(opts.args...) if action.action == opts.action
#     return(views)
    


#   # Pinkman manipulates templates through View.
#   # View is always associated with a controller.
#   # A controller contains methods (actions) which responds to js events.
#   @view = (id,controller) ->
#     if controller?
#       $(document).ready ->

#         selector = Pinkman.helper.createSelector(id)
        
#         if $(selector).length
          
#           view = new PinkmanObject
#           view.set('id',id)
#           view.actions = new PinkmanCollection
#           view.set('selector',selector)

#           p = new Object

#           view.set('view',p)
#           window.Pinkman.activeViews.push(view) unless window.Pinkman.activeViews.getBy('selector',view.selector)?

#           p.executeAction = (action,eventName,callback) ->
#             $("body").on eventName, "##{id} [data-action='#{action}']", (ev) ->
#               # console.log "execute action => in view: #{id} => call action: #{action} => on: #{eventName}"
#               ev.preventDefault() unless eventName == 'keypress'
#               pinkey = $(this).data("pinkey") if $(this).is("[data-pinkey]")
#               obj = PinkmanGlue.all[pinkey]
#               callback(obj,$(this),ev)


#           p.action = (action,eventName,callback) ->
#             a = new PinkmanObject
#             a.assign action: action, eventName: eventName, callback: callback
#             view.actions.push a
#             # console.log "define action => in view: #{id} => call action: #{action} => on: #{eventName}"
#             if typeof eventName == "string"
#               @executeAction(action,eventName,callback)
#             else if eventName instanceof Array
#               @executeAction(action,e,callback) for e in eventName

#           p.trigger = (action,eventName,options...) ->
#             a = view.actions.getByAttributes
#               action: action
#               eventName: eventName
#             a.callback(options...) if a?

#           p.endOfPage = (callback) ->      
#             setTimeout ->        
#               window.lastEndOfPage = 0
#               $(window).scroll ->
#                 t = Date.now()
#                 # console.log 'altura'
#                 # console.log ($(document).height() - $(window).scrollTop() - document.body.offsetHeight < 800)
#                 # console.log 'tempo'
#                 # console.log (window.lastEndOfPage < t)
#                 # console.log 'endOfPageRunning'
#                 # console.log window.endOfPageRunning
#                 if ((($(document).height() - $(window).scrollTop() - document.body.offsetHeight < 800) and (window.lastEndOfPage) < t) or ($(document).height() - $(window).scrollTop() - document.body.offsetHeight == 0)) and not window.endOfPageRunning
#                   window.endOfPageRunning = true
#                   # console.log 'triggou end of page'
#                   window.lastEndOfPage = t
#                   callback()
#             , 200

#           p.finishEndOfPage = () ->
#             window.endOfPageRunning = false

#           constructObjFromArray = (obj,array,i=0) ->
#             obj = new Object unless typeof obj=='object'
#             if i < array.length
#               obj[array[i]] = constructObjFromArray(obj[array[i]],array,i+1)
#               return obj
#             else
#               return(new Object)

#           p.bindAll = ->
#             Pinkman.callOnce ->
#               array = []
#               $(selector).find("[name]").each (i,el) ->
#                 array.push($(el).attr('name')) if array.indexOf($(el).attr('name')) == -1
              
#               p.bind(name) for name in array
#               # console.log array

#           p.bind = (attrs...) ->
#             callback = attrs.pop() if typeof attrs[attrs.length-1]=='function'
#             mainAttr = attrs.pop()
#             @action mainAttr,['keyup','change'], (obj,jquery) ->
#               # console.log obj
#               Pinkman.callOnce ->
#                 # console.log 'chamou bind once'
#                 obj.assign  constructObjFromArray(obj,attrs)
#               aux = obj
#               aux = aux[attr] for attr in attrs
#               if aux[mainAttr] != jquery.val()             
#                 if aux.isPink 
#                   aux.set(mainAttr,jquery.val())
#                 else
#                   aux[mainAttr] = jquery.val()
#                 callback(obj,jquery) if callback? and typeof callback == 'function'

#           # drop
#           ## -- usage: 
#           ## v.drop 'action', 
#           ##   enter: callback(obj,jquery,event)  -  when user dragging enters 'action'
#           ##   over: callback(obj,jquery,event)   -  when user dragging is over 'action'
#           ##   leave: callback(obj,jquery,event)  -  when user dragging leaves 'action'
#           ##   drop: callback(obj,jquery,event)   -  when user drops something in 'action'
#           ##   files: callback(obj,files)         -  captures whatever user droped in 'action'

#           p.drop = (action,options) ->
#               p.action action, 'click', (obj,j,ev) ->
#                 options.click(obj,j,ev) if options.click? and typeof options.click == 'function'
#               p.action action, 'dragenter', (obj,j,ev) ->
#                 options.enter(obj,j,ev) if options.enter? and typeof options.enter == 'function'
#               p.action action, 'dragover', (obj,j,ev) ->
#                 options.over(obj,j,ev) if options.over? and typeof options.over == 'function'
#               p.action action, 'dragleave', (obj,j,ev) ->
#                 options.leave(obj,j,ev if options.leave? and typeof options.leave == 'function')
#               p.action action, 'drop', (obj,j,ev) ->
#                 options.drop(obj,j,ev) if options.drop? and typeof options.drop == 'function'
#                 options.files(obj,ev.originalEvent.dataTransfer.files) if options.files? and typeof options.files == 'function'

#           # autcomplete feature
#           # description - search through a certain collection, display a list and callback when the user selected someone from the list.

#           # usage: p.autocomplete(object)

#           # object.attribute: attribute from the object who generated the form that is going to be autocompleted
#           # object.with: a collection that is going to be searched/filtered
#           # object.display: what attribute from the collection that is going to be displayed in the list
#           # object.filter: name of the function or function to filter the collection according to what user is typing
#           # object.callback: what to do after user select someone from the list

#           p.autocomplete = (options) ->
#             window.options = options
#             if options? and typeof options == 'object'
#               options.filter = 'search' unless options.filter?
#               options.display = 'name' unless options.display?

#               @action "autocomplete-for-#{options.attribute}", 'click', (selected,j) ->
#                 if options.callback? and typeof options.callback == 'function'
#                   options.callback(selected.autocomplete.origin,selected,j) 

#                   # keep form focus in the right place
#                   formAttributes = $("[data-pinkey='#{selected.autocomplete.origin.pinkey}'][name]")
#                   thisAttribute = formAttributes.closest("[name='#{options.attribute}']")
#                   nextAttribute = formAttributes[formAttributes.index(thisAttribute)+1]
#                   nextAttribute.focus() if nextAttribute?

#               @bind options.attribute, (o,j) =>
#                 NProgress.start()
#                 clearTimeout(window.pinkmanAutocompleteBinding)
#                 doAfter 8, ->
#                   query = o[options.attribute]
#                   j.parent().find('.autocomplete').show()
#                   if query? and query != ''
#                     setupAndRender = (c) ->
#                       c.makeIndex()
#                       c.each (obj) ->
#                         obj.set('autocomplete', {origin: o,attribute: options.attribute})
#                         if typeof options.display == 'function' then obj.set('display',options.display(obj)) else obj.set('display',obj[options.display]) 
#                       c.render
#                         template: 'autocomplete-template'
#                         target: "autocomplete-#{options.attribute}-#{o.pinkey}"
#                       NProgress.done()

#                     if options.filter? and typeof options.filter == 'function'
#                       options.filter options.with,query, (c) ->
#                         setupAndRender(c)
#                     else
#                       c = options.with
#                       c[options.filter] query, (c) ->
#                         setupAndRender(c)
#                   else
#                     j.parent().find('.autocomplete').hide()
#                     NProgress.done()

#                 , 'pinkmanAutocompleteBinding'

#           controller(p)

#           p.main() if p.main? and typeof p.main == 'function'
#     else
#       @getView(id)

#   # same as view but can only be open/defined once.
#   @uniqView: (id,controller) ->
#     @view(id,controller) unless Pinkman.isViewActive(id)

#   @popstate: () ->
#     if window? and history? and history.pushState?
#       unless @popstateActivated
#         @popstateActivated = true
#         window.onpopstate = (event) ->
#           Pinkman.get(event.state.pinkey).reRender()
  
#   @callOnce: (f,args...) ->
#     if typeof f == 'function'
#       func = f.toString()
#       if @calledFunctions.indexOf(func) == -1
#         @calledFunctions.push(func)
#         f(args)

#   @calledFunctions = []

#   @ajax: 
#     get: (options) ->
#       if options.url?
#         ajax = jQuery.ajax options.url,
#           type: "GET"
#           dataType: 'json'
#         ajax.done (response) =>
#             if response.errors?
#               options.error(response) if options.error? and typeof options.error == 'function'
#               return false
#             else
#               options.success(response) if options.success? and typeof options.success == 'function'
#             options.complete(response) if options.complete? and typeof options.complete == 'function'
#           return this
#       else
#         return false

#     post: (options) ->
#       if options.url?
#         ajax = jQuery.ajax options.url,
#             beforeSend: (xhr) -> 
#               xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
#             type: "POST"
#             dataType: 'json'
#             data: options.data
#         ajax.done (response) =>
#           if response.errors?
#             options.error(this) if options.error? and typeof options.error == 'function'
#             return false
#           else
#             options.success(response) if options.success? and typeof options.success == 'function'
#           options.complete(response) if options.complete? and typeof options.complete == 'function'
#         return this
#       else
#         return false

#     put: (options) ->
#       if options.url?
#         ajax = jQuery.ajax options.url,
#             beforeSend: (xhr) -> 
#               xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
#             type: "PUT"
#             dataType: 'json'
#             data: options.data
#           ajax.done (response) =>
#             if response.errors?
#               options.error(this) if options.error? and typeof options.error == 'function'
#               return false
#             else
#               options.success(response) if options.success? and typeof options.success == 'function'
#             options.complete(response) if options.complete? and typeof options.complete == 'function'
#           return this
#       else
#         return false


#     file: (options) ->
#       if options.url?
#         ajax = jQuery.ajax options.url,
#             beforeSend: (xhr) -> 
#               xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
#             xhr: ->
#               myXhr = $.ajaxSettings.xhr()
#               myXhr.upload.addEventListener 'progress', (e) ->
#                   if e.lengthComputable
#                     options.progress e.loaded/e.total if options.progress?
#                 , false
#               myXhr.addEventListener 'progress', (e) ->
#                   if e.lengthComputable
#                     options.progress e.loaded/e.total if options.progress?
#                 , false
#               return myXhr
#             type: "POST"
#             dataType: 'json'
#             data: options.data
#             processData: false
#             contentType: false
#         ajax.done (response) =>
#           if response? and response.errors?
#             options.error(this) if options.error? and typeof options.error == 'function'
#             return false
#           else
#             options.success(response) if options.success? and typeof options.success == 'function'
#           options.complete(response) if options.complete? and typeof options.complete == 'function'
#         return this
#       else
#         return false

#     upload: (options...) ->
#       @file(options...)

# $(document).ready ->
#   unless Pinkman.pathname?
#     Pinkman.pathname = window.location.pathname
#     Pinkman.pathname = Pinkman.pathname + '/' if Pinkman.pathname.charAt([Pinkman.pathname.length] - 1) != "/"