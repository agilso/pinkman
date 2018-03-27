class window.PinkmanCache
  
  @_caching = new Object
  
  @md5: (args...) ->
    md5(args...)
    
  @cache: (name,value) ->
    @_caching[name] = value
  
  @has: (name) ->
    @_caching[name]?
    
  @get: (name) ->
    @_caching[name]
    
$(document).ready ->
  window.$c = window.PinkmanCache