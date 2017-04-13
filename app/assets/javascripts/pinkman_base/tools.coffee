window.sleep = (s,callback) -> 
  ms = s*1000
  window['_sleeping'] = setTimeout(callback,ms)
    