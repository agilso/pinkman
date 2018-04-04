class window.PinkmanCommon
  
  @privateAttributes = ['isPink','isObject','isCollection','pinkey','config','pinkmanType','collections','renderQueue','_listening']
  
  constructor: (attributesObject) ->
    @_listening = true
    @isPink = true
    @pinkey = Pinkman.all.length
    Pinkman.all.push(this)
    @initialize(attributesObject) if attributesObject?

  @mixin: (args...) ->
    Pinkman.mixin(args...)

  # DEPRECATED in favor of mix (bellow)
  @mixit: (args...) ->
    Pinkman.mixit(this,args...)
  
  @mix: (args...) ->
    Pinkman.mix(this,args...)

  @isInstance: (object) ->
    object.constructor is this
    
  initialize: (attributesObject) ->
    if typeof attributesObject == 'object'
      for key, value of attributesObject
        @set(key,value) if PinkmanObject.privateAttributes.indexOf(key) is -1

  # Desc: return api url path
  api: (paths...) ->
    if @config? and @config.api?
      if @config.api.charAt(0) == '/'
        url = @config.api + '/'
      else
        url = '/' + @config.api + '/'
    url = url + paths.join('/') if paths.length
    return(url)

  isInstanceOf: (prot) ->
    this.constructor is prot

  # Desc: returns the class name (constructor name)
  # Usage: a.className()  #=> a.constructor.name
  className: ->
    if @config? and @config.className?
      @config.className
    else
      @constructor.name

  # Desc: set a pair of key/value for this object. Triggers reRender if watch is active.
  # Usage:
  # a.set 'a', 'b', (a) ->
    # do something with a
  set: (attr,value, callback = "" ) ->
    if attr? and value?
      this[attr] = value
      callback(this) if typeof callback == 'function'
      if @pinkey? and @_listening
        sId = "__pSync__#{@pinkey}__"
        clearTimeout(window[sId]) if window[sId]?
        window[sId] = $p.sleep 0.005, =>
          # console.log "syncing #{@pinkey}"
          @sync(attr) if @_listening
      return this
      
  sync: (attribute) ->  
    if @constructor.__computed?
      for c in @constructor.__computed 
        # console.log "computar: #{this.pinkey} #{this[c].call(this)}"
        Pinkman.sync(this, c, this[c].call(this)) if this[c]? and typeof this[c] == 'function'
        
    if attribute? and attribute!=''
      Pinkman.sync(this, attribute, this[attribute])
    else
      Pinkman.sync(this, k, v) for k, v of @attributes()
    true
  
  lazySync: (args...)->
    $p.sleep 0.25, =>
      @sync(args...)
    
  stop: ->
    console.log '[deprecated] stop function deprecated. Use unwatch instead.'
    @_listening = no
  
  watch: ->
    @_listening = yes
  
  unwatch: ->
    @_listening = no
    
  # Desc: sets the attribute as undefined (destroy attribute)
  unset: (attr,callback) ->
    delete this[attr]
    callback(this) if typeof callback == 'function'
    this

  # --- Render related --- #

  # Desc: log attr value in the console
  log: (attr) ->
    console.log this[attr]
    
  render: (options,callback) ->
    if typeof options == 'object'
      options.object = this
      Pinkman.render options
    else if typeof options == 'string'
      opts = {object: this, target: options, template: options + '-template', callback: callback}
      Pinkman.render opts
    else
      @reRender()

  reRender: (callback='') ->
    Pinkman.reRender(this)
    callback(this) if typeof callback == 'function'
    return this
  
  renderFirst: () ->
    Pinkman.render @renderQueue.first()
    
  renderLast: () ->
    Pinkman.render @renderQueue.last()


  append: (options) ->
    if options? and typeof options == 'object' and options.target?
      options.template = options.target + '-template' unless options.template? and options.template != ''
      newOptions = new Object
      for k,v of options
        newOptions[k] = v if k != 'target' and k != 'callback'
      newOptions.reRender = no
      target = options.target
      wrapIn = options.wrapIn
      newOptions.object = this
      newOptions.callback = (object,content) ->
        if wrapIn?
          $('#'+target).append("<div class='#{wrapIn}'>#{content}</div>")
        else
          $('#'+target).append(content)
        options.callback(object,content) if options.callback? and typeof options.callback == 'function'
      Pinkman.render(newOptions)
    else if options? and Pinkman.isString(options)
      @append
        template: options + '-template'
        target: options

  _queue: (options) ->
    options.id = options.template
    @renderQueue = new PinkmanCollection unless @renderQueue?
    @renderQueue.directPush(options)

  hasError: ->
    @errors?
  
  hasErrors: ->
    @hasError()

  hasErrorOn: (attr) ->
    if attr? and (Pinkman.isArray(attr) or Pinkman.isString(attr))
      array = if Pinkman.isArray(attr) then attr else [attr]
      valid = true
      if @errors?
        for a in array
          valid = false if @errors[a]?
      !valid

  hasErrorsOn: (args...) ->
    @hasErrorOn(args...)

  anyErrorOn: (args...) ->
    @hasErrorOn(args...)

  anyErrorsOn: (args...) ->
    @hasErrorOn(args...)

  _data: ->
    { pink_obj: @json(), scope: Pinkman.scope(this) }
  
  # computed Functions
  # computed functions cant have arguments
  @compute: (f) ->
    @__computed ||= []
    if @__computed.indexOf(f) != -1 
      # console.log "colocou f"
      @__computed.push(f) 
    else
      # console.log "não colocou f"
      @__computed.push(f) 