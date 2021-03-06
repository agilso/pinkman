class window.PinkmanPath extends Pinkman.object
   
  constructor: (url) ->
    if PinkmanCache.has("p-path-#{url}")
      return(PinkmanCache.get("p-path-#{url}"))
    else
      # setting params
      paramsRegex = /\?.*/
      if paramsRegex.test(url)
        paramsString = /\?(.*)/.exec(url)[1]
        @query = JSON.parse('{"' + decodeURI(paramsString).replace(/"/g, '\\"').replace(/&/g, '","').replace(/=/g,'":"') + '"}')
        url = url.replace("?#{paramsString}", '')
      
      
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
        PinkmanCache.cache("p-path-#{url}", this)
      
  @depth: (url) ->
    a = url.split('/')
    a.shift() if a[0] == ''
    a.pop() if a[a.length-1] == ''
    a.length
    
  @isExternal: (url) ->
    urlRegex = new RegExp('^(?:[a-z]+:)?//', 'i')
    hostRegex = new RegExp(window.location.origin,'i')
    urlRegex.test(url) and not hostRegex.test(url)
  
  @isInternal: (url) ->
    not @isExternal(url)
          
  level: (index) ->
    @levels.getBy('index',index)
    
  lastLevel: ->
    @levels.last()
  
  match: (path) ->
    # console.log "PinkmanPath#match - path arg: #{path}"
    path = new PinkmanPath(path) if Pinkman.isString(path)
    if PinkmanPath.isInstance(path) and path.depth == @depth
      # console.log 'tentou'
      match = true
      @static.each (level) ->
        if level.entry != path.level(level.index).entry
          # console.log level.entry
          # console.log path.level(level.index).entry
          match = false 
      return(match)
    else
      false
  
  matchParams: (path) ->
    @dynamic.each (level) ->
      # console.log level
      # console.log path
      path.params[level.entry.replace(/:/g,"")] = path.level(level.index).entry.replace(/[#?].*/,'')
  
  deduceControllerName: ->
    @static.extract('entry').join('-').replace(/[\/_]/g,'-').replace(/^-/,'')

# receives a string and matches it through the defined routes
class window.PinkmanRouteMatcher extends Pinkman.object
  
  initialize: (callback) ->
    if @controllers.any()?
      Pinkman.controllers.unbindScrolling()
      # console.log 'clear dos Pinkman.controllers'
      
      @controllers.each (c) =>
        # console.log 'dentro dos controllers desse router'
        c.setParams(@params())
        c.build(yes, this)
      , =>
        callback(this.route, this.url) if typeof callback == 'function'
    else
      false
  
  # removes old pink-yield div and inserts this one (new/current)
  makeYielder: ->
    $(@yieldIn).html("<div class='pink-yield' id='#{@controller}'></div>") if @yieldIn and @route.blank
    
  match: (url) ->
    if url?
      route = @findRouteFor(url)
      if route?
        return(@setup(route,url))
      else
        return(false)  
    
  findRouteFor: (url) ->
    url = url.replace(window.location.origin,'') if PinkmanPath.isInternal(url)
    # console.log 'tentando achar route'
    # console.log(url)
    if PinkmanCache.has("p-router-#{url}")
      PinkmanCache.get("p-router-#{url}")
    else
      r = Pinkman.routes
        .select(depth: PinkmanPath.depth(url))
        .select((candidate) -> candidate.path.match(url))
        .sortBy('staticDepth','desc').first()
      return(PinkmanCache.cache("p-router-#{url}", r))
  
  setup: (route, url) ->
    if route? and url?
      # console.log "PinkmanRouterMatcher#setup - url arg: #{url}"
      urlPath = new PinkmanPath(url) 
      route.path.matchParams(urlPath)
      @set('url', url)
      @set('path', urlPath)
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
    Pinkman.mergeObjects(@path.params, @path.query)
    
    
# every route defined turn into a object of this class: PinkmanRoute
class window.PinkmanRoute extends Pinkman.object    
  yieldIn: ->
    @yield || @container 
    
  # handleNamespacedController
  # Desc: Forces a namespaced controller to start with the namespace name.
  # Example 1:
  #  routes.namespace 'admin', (routes) ->
  #     routes.match 'abc', controller: 'abc'
  # The controller name will be set to 'admin-abc'.
  # Example 2:
  #  routes.namespace 'admin', (routes) ->
  #     routes.match 'abc', controller: 'admin-abc'
  # The controller name remains 'admin-abc'.
  
  handleNamespacedController: (namespace) ->
    @set('controller',"#{namespace.replace(/\//g,'-')}-#{@controller}") if namespace and @controller and not (new RegExp("^#{namespace}")).test(@controller)

  definePathHelper: ->
    helperName = @path.deduceControllerName().replace(/-/g,'_') + '_path'
    Pinkman.path_helpers.push helperName
    $p.defineGlobalVar helperName, (args...) =>
      i = 0
      array = []
      for level in @path.levels.collection
        if level.dynamic
          array.push(args[i])
          i = i + 1
        else
          array.push(level.entry)
      '/' + array.join('/')
        
  
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
  
  @scrolling = new PinkmanCollection
  
  @saveWindowScroll = (id) ->
    @scrolling.firstOrInitialize(id: id).set('position', window.scrollY)
 
  @restoreWindowScroll = (id) ->
    o = @scrolling.firstOrInitialize(id: id)
    # console.log o.position
    o.position = 0 unless o.position?
    window.scrollTo(0,o.position)
  
  @analytics: 
    create: (id) ->
      try
        ga('create', id, 'auto');
        ga('send', 'pageview');
        true
      catch 
        console.log('ga blocked')
        false
        
      
    send: (route,path) ->
      unless @created? and @created
        # console.log this
        @created = @create(Pinkman.router._config.analytics)
      else
        host = new RegExp(window.location.origin)
        path = if host.test(path) then path.replace(host,'') else path
        ga('set', 'page', path)
        ga('send', 'pageview', path)

  @render: (r, callback) ->
    @saveWindowScroll(Pinkman.routes.current.controller) if Pinkman.routes.current?
    Pinkman.state.initialize()
    r.yieldIn = r.route.yieldIn() || @_config.yield
    r.initialize (args...) =>
      @analytics.send(args...) if @_config.analytics?
      callback() if typeof callback == 'function'
      @_config.after(@currentMatcher, @previousMatcher) if typeof @_config.after == 'function'
    Pinkman.routes.set('current',r.route)
    unless Pinkman.router._config.freeze or (r.options? and r.options.freeze)
      # console.log 'topo'
      window.scrollTo(0,0)
    else
      $p.sleep 0.15, =>
        @restoreWindowScroll(r.route.controller)
    true
    
  # Search path throughout routes. On match, activate respective controllers: clears template and execute main(s) function(s)
  @activate: (path, callback, options) ->
    r = Pinkman.routes.match(path)
    if r? and r
      @previousMatcher = @currentMatcher if @currentMatcher?
      
      if @previousMatcher? 
        @previousMatcher.controllers.each (c) ->
          c.clearSubscriptions()
        
      @currentMatcher = r
      # console.log r
      r.options = options
      @_config.before(@currentMatcher, @previousMatcher) if $p.isFunction(@_config.before)
      if @_config.transition? and typeof @_config.transition == 'function'
        @_config.transition =>
          @render(r, callback)
      else
        @render(r, callback)
    else
      # console.log 'route not found'
      false
    
  @path: ->
    window.location.pathname
  
  # Helper for composing the current url with a new params  
  @composePath: (obj) ->
    if $p.isObject(obj)
      $p.json2url($r.path(),($p.mergeObjects $r.paramsObject(), obj))
    else
      throw "Pinkman Router $r: composePath called with wrong args: #{obj}"
  
  # Goes to a path
  @visit: (path) ->
    @activate path, ->
      Pinkman.state.push(path)
  
  @force: (path) ->
    @location(path) unless @visit(path)
  
  @location: (path) ->
    window.location = path
  
  @restore: (path) ->
    (window.location=path) unless @activate(path,null,{freeze: yes})
  
  @redirect: (args...) ->
    @force(args...)
  
  @redirectTo: (args...) ->
    @force(args...)
    
  @go: (args...) ->
    @force(args...)
  
  @to: (args...) ->
    @force(args...)
    
  
  @forward: ->
    window.history.forward() if window.history?
  
  @back: ->
    window.history.back() if window.history?
    
  @refresh: ->
    @go(@path())
    
  @reload: ->
    window.location.reload()
  
  @paramsObject: ->
    regex = /\?(.*)/
    if regex.test(window.location.href)
      paramsString = regex.exec(window.location.href)[1]
      JSON.parse('{"' + decodeURI(paramsString).replace(/"/g, '\\"').replace(/&/g, '","').replace(/=/g,'":"') + '"}')
    else
      return new Object
    
  @start: ->
    Pinkman.ready =>
      Pinkman.router = this
      App.router = this
      window.$r = App.router
      @activate(window.location.href)
      $('body').on 'click', 'a:not([data-pinkman="false"],[target="blank"],[target="_blank"])', (ev) =>
        ev.preventDefault()
        path = ev.currentTarget.href
        @location(path) unless path? and @visit(path)
  
  namespace: (namespace, rules) ->
    namespace = namespace.replace(/^\//,'')
    namespaced = new @constructor()
    namespaced._namespace = if @_namespace then ("#{@_namespace}/#{namespace}") else namespace
    rules(namespaced) if typeof rules == 'function'
    
  scope: (scope, rules) ->
    scope = scope.replace(/^\//,'')
    scoped = new @constructor()
    scoped._scope = if @_scope then ("#{@_scope}/#{scope}") else scope
    rules(scoped) if typeof rules == 'function'
    
  resources: (resourceName) ->
    
    # controllerPrefix = if @_namespace then @_namespace.replace(/\//,'-') + '-' else ''
    
    resourceName = resourceName.replace(/\/$/,'')
    controllerName = resourceName.replace(/[\/_]/g,'-').replace(/^-/,'')
    
    # index
    @match resourceName, controller: controllerName + '-index'
    # new
    @match resourceName + '/new', controller: controllerName + '-new'
    # edit
    @match resourceName + '/:id/edit', controller: controllerName + '-edit'
    # show
    @match resourceName + '/:id', controller: controllerName + '-show'

    
  match: (path, object) ->
    if Pinkman.isString(path)
      path = path.replace(/^\//,'')
      path = "/#{@_namespace}/" + path if @_namespace
      path = "/#{@_scope}/" + path if @_scope
      p = new PinkmanPath(path)
      route = new PinkmanRoute
      route.set('id',path)
      route.set('url',path)
      route.set('path',p).set('depth',p.depth).set('staticDepth',p.staticDepth).set('dynamicDepth',p.dynamicDepth)
      route.set('blank',yes) 
      route.set('controller', if object? and object.controller? then object.controller else p.deduceControllerName())
      
      # handle namespaced controller name (add namespace prefix)
      route.handleNamespacedController(@_namespace)
      
      route.definePathHelper()
      
      if object? and typeof object == 'object' 
        route.set('blank',no) if (object.keep? and object.keep) or (object.blank? and not object.blank)
        route.set('yield',object.container || object.yield )
      Pinkman.routes.push(route)
      return(route)
      
  get: (args...) ->
    console.log 'Routes: "get" function deprecated. Use match instead.'
    match(args...)
    
    
  root: (controller) ->
    @match('/',controller: controller)
  
Pinkman.router = PinkmanRouter
Pinkman.path_helpers = []