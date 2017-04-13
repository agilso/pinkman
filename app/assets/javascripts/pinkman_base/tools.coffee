window.sleep = (s,callback) -> 
  ms = s*1000
  window['_sleeping'] = setTimeout ->
    callback()
    window._sleeping_since = null
  , ms
    