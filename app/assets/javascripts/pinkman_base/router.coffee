class window.PinkmanPath extends Pinkman.object
   
  constructor: (url) ->
    @levels = new Pinkman.collection
    @static = new Pinkman.collection
    @dynamic = new Pinkman.collection
    @params = new Object
    super()
    if Pinkman.isString(url)
      url = url.replace(window.location.origin,'') if PinkmanPath.isInternal(url)
      a = url.split('/')
      a.shift() if a[0] == ''
      a.pop() if a[a.length-1] == ''
      i = 0
      s = 0
      d = 0
      for l in a
        i = i + 1
        obj = new Pinkman.object({entry: l, index: i})
        if /:/.test(l[0])
          d = d + 1
          obj.set('dynamic',yes)
          obj.set('static',no)
          @dynamic.push(obj)
        else
          s = s + 1
          obj.set('dynamic',no)
          obj.set('static',yes)
          @static.push(obj)
        @levels.push(obj)
      
      @set('depth',i)
      @set('staticDepth',s)
      @set('dynamicDepth',d)
      
  
  @isExternal: (url) ->
    urlRegex = new RegExp('^(?:[a-z]+:)?//', 'i')
    hostRegex = new RegExp(window.location.origin,'i')
    urlRegex.test(url) and not hostRegex.test(url)
  
  @isInternal: (url) ->
    not @isExternal(url)
          
  level: (index) ->
    @levels.getBy('index',index)
  
  match: (path) ->
    path = new PinkmanPath(path) if Pinkman.isString(path)
    if PinkmanPath.isInstance(path) and path.depth == @depth
      match = true
      @static.each (level) ->
        match = false if level.entry != path.level(level.index).entry
      if match
        @dynamic.each (level) ->
          path.params[level.entry.replace(/:/g,"")] = path.level(level.index).entry
      return(match)
    else
      false
    

# receives a string and matches it through the defined routes
class window.PinkmanRouteMatcher extends Pinkman.object
  
  initialize: ->
    if @controllers.any()?
      Pinkman.controllers.unbindScrolling()
      # console.log 'clear dos Pinkman.controllers'
      @controllers.each (c) =>
        # console.log 'dentro dos controllers desse router'
        c.setParams(@params())
        c.build(yes)
    else
      false
    
  match: (url) ->
    path = new PinkmanPath(url)
    if path?
      candidates = Pinkman.routes.select(depth: path.depth)
      routes = candidates.select (candidate) ->
        candidate.path.match(path)
      route = routes.sortBy('staticDepth','desc').first()
      if route?
        @set('url',url)
        @set('path',path)
        @set 'route', route
        @set 'controller', @route.controller
        @set('controllers', Pinkman.controllers.select(id: @controller))
        if @controllers.any()
          return(this) 
        else 
          throw "(Pinkman Route) Controller '#{@route.controller}' not found."
      else
        return(false)
    
  params: ->
    # console.log @path
    # console.log @path.params
    @path.params if @path and @path.params?
    
    
# every route defined turn into a object of this class: PinkmanRoute
class window.PinkmanRoute extends Pinkman.object    
  yieldIn: ->
    @yield || @container 

  
# Routes collection. Have the capability to search a string through routes and storage all defined routes. Used once in Pinkman.routes
class window.PinkmanRoutes extends Pinkman.collection
  config:
    className: 'PinkmanRoutes'
    memberClass: ->
      return (new PinkmanRoute)
    
  match: (url) ->
    matcher = new PinkmanRouteMatcher
    return(matcher.match(url))
# global variable to store routes
Pinkman.routes = new PinkmanRoutes

# Main class: define routes throughout the application
class window.PinkmanRouter
  
  # Sets the global container of the application.
  # Everything will be yield inside this container. This container is just simple valid(present) selector that will serve as a wrapper for things to be dynamically rendered in.
  @config: (value) ->
    $(document).ready =>
      if value? and typeof value == 'object' and value.yield?
        @_config = value 
        throw 'PinkmanRouter Config: yield must be a valid(present) selector' if $(@_config.yield).length == 0
      else
        throw '(Pinkman Router) Config argument must be a object and must have yield attribute.'
  
  # This function is responsible for defining our app routes
  # It is manipulated by the final user
  @define: (routes) ->
    router = new PinkmanRouter
    routes(router) if typeof routes == 'function'
    return(router)
  
 
  # Search path throughout routes. On match, activate respective controllers: clears template and execute main(s) function(s)
  @activate: (path,callback) ->
    r = Pinkman.routes.match(path)
    if r? and r
      Pinkman.state.initialize()
      yieldIn = r.route.yieldIn() || @_config.yield 
      $(yieldIn).html("<div class='pink-yield' id='#{r.controller}'></div>") if r.route.blank
      r.initialize()
      window.scrollTo(0,0) unless Pinkman.router._config.freeze
      callback() if typeof callback == 'function'
      true
    else
      false
    
  # Goes to a path
  @visit: (path) ->
    @activate path, ->
      Pinkman.state.push(path)
      
  @force: (path) ->
    (window.location=path) unless @visit(path)
      
  @restore: (path) ->
    (window.location=path) unless @activate(path)
  
  @redirect: (args...) ->
    @force(args...)
  
  @redirectTo: (args...) ->
    @force(args...)
    
  @go: (args...) ->
    @force(args...)
    
  @start: ->
    Pinkman.ready =>
      Pinkman.router = this
      @activate(window.location.pathname)
      $('body').on 'click', 'a', (ev) =>
        ev.preventDefault()
        path = ev.currentTarget.href
        (window.location = path) unless path? and @visit(path)
  
  # namespace: (path, rules) ->
      
  get: (path, object) ->
    if Pinkman.isString(path)
      p = new PinkmanPath(path)
      route = new PinkmanRoute
      route.set('id',path)
      route.set('url',path)
      route.set('path',p).set('depth',p.depth).set('staticDepth',p.staticDepth).set('dynamicDepth',p.dynamicDepth)
      route.set('blank',yes)
      route.set('controller', if object? and object.controller? then object.controller else p.level(1).entry)
      if object? and typeof object == 'object' 
        route.set('blank',no) if (object.keep? and object.keep) or (object.blank? and not object.blank)
        route.set('yield',object.container|| object.yield )
      Pinkman.routes.push(route)
      return(route)
    
  root: (controller) ->
    @get('/',controller: controller)
  
# motivation
# class window.AppRouter extends PinkmanRouter
#   
# AppRouter.config yield: 'body'
# 
# AppRouter.define (r) ->
#   
#   # @namespace 'lol', =>
#   #   @get 'test'
#   #   # define /lol/test
#   # 
#   # 
#   # @get 'produto/:id',
#   #   controller: 'produto'
#   # #define /produto/qualquer-coisa
#   # # controler.param.id = 'qualquer-coisa'
#   #   
#     
#     
#   @get 'test',
#     controller: 'test'
#     
#     ->
#       header
#         title Lol
#       body#test
#         execute 'controller.test.main'
# 
# AppRouter.visit 'test'