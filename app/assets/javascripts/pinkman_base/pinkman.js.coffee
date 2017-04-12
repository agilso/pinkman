class window.Pinkman

  # --- objects and collections manipulation

  @collections = []
  @objects = []
  @all = []

  @get: (pinkey) ->
    this.all[pinkey]

  # --- predicate

  @isNumber: (n) ->
    !isNaN(parseFloat(n)) && isFinite(n)

  @isArray: (array) ->
    array? and array.constructor is Array

  # --- tools and facilities

  @doAfter: (ds, callback, timer = '_pinkman_doAfter') ->
    window[timer] = window.setTimeout ->
      callback() if typeof callback == 'function'
    , ds*100

  @clearTimeout: (timerName = '_pinkman_doAfter') ->
    window.clearTimeout(window[timerName])

  @defineGlobalVar: (variable,value) ->
    window[variable] = value
  
  @onlyOnce: (f,args...) ->
    if typeof f == 'function'
      
      func = new Object
      func.f = f.toString()
      func.args = args

      if @calledFunctions.indexOf(func) == -1
        @calledFunctions.push(func)
        f(args)

  @calledFunctions = []