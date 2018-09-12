class window.PinkmanCache
  
  @_caching = new Object
  
  @md5: (args...) ->
    md5(args...)
    
  @cache: (name,value) ->
    @_caching[name] = value
  
  @has: (name) ->
    @_caching[name]?
  
  @getOrInsert: (name, value) =>
    if @has(name) 
      # console.log "has: #{name}"
      return(@get(name)) 
    else
      # console.log "caching: #{name}"
      return(@cache(name, value))
    
  @get: (name) ->
    @_caching[name]
    
$(document).ready ->
  window.$c = window.PinkmanCache