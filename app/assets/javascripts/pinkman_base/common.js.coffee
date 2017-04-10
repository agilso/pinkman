class window.PinkmanCommon
  
  @isInstance: (object) ->
    object.constructor is this

  isInstanceOf: (prot) ->
    this.constructor is prot

  # Desc: return api url path
  apiUrl: () ->
    @config.apiUrl

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
      @reRender() if @watch
      return true

  # --- Render related --- #

  render: (options) ->
    if typeof options == 'object'
      options.object = this
      Pinkman.render options

  reRender: (options) ->
    if typeof options == 'object'
      options.object = this
      Pinkman.reRender options    
