class window.PinkmanCommon

  constructor: (attributesObject) ->
    @initialize(attributesObject) if attributesObject?

  @privateAttributes = ['isPink','isObject','isCollection','pinkey','config','pinkmanType','collections','renderQueue']
  
  @mixin: (args...) ->
    Pinkman.mixin(args...)

  @mixit: (args...) ->
    Pinkman.mixit(this,args...)

  @isInstance: (object) ->
    object.constructor is this


  initialize: (attributesObject) ->
    if typeof attributesObject == 'object'
      for key, value of attributesObject
        @set(key,value) if PinkmanObject.privateAttributes.indexOf(key) is -1


  # Desc: return api url path
  api: () ->
    if @config? and @config.api?
      if @config.api.charAt(0) == '/'
        @config.api + '/' 
      else
        '/' + @config.api + '/' 
  
  isInstanceOf: (prot) ->
    this.constructor is prot

  # Desc: returns the class name (constructor name)
  # Usage: a.className()  #=> a.constructor.name
  className: ->
    @constructor.name
  
  # Desc: set a pair of key/value for this object. Triggers reRender if watch is active.
  # Usage:
  # a.set 'a', 'b', (a) ->
    # do something with a
  set: (attr,value, callback = "" ) ->
    if attr? and value?
      this[attr] = value
      callback(this) if typeof callback == "function"
      @reRender() if @_watching
      return true

  # --- Render related --- #

  render: (options) ->
    if typeof options == 'object'
      options.object = this
      Pinkman.render options
    else if typeof options == 'string'
      opts = {object: this, target: options, template: options + '-template'}
      Pinkman.render opts

  reRender: () ->
    Pinkman.reRender this    

  watch: () ->
    @_watching = yes

  queue: (options) ->
    @renderQueue = new PinkmanCollection unless @renderQueue?
    @renderQueue.directPush(options)
