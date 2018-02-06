class window.Pinkman

  # --- objects and collections manipulation

  @collections = []
  @objects = []
  @all = []

  @get: (pinkey) ->
    this.all[pinkey]

  @count: () ->
    @all.length

  # --- predicate

  @isNumber: (n) ->
    !isNaN(parseFloat(n)) && isFinite(n)

  @isArray: (array) ->
    array? and array.constructor is Array

  @isString: (str) ->
    str? and typeof str == 'string'
  
  @isPrintable: (value) ->
    @isString(value) or @isNumber(value)
    
  @isObject: (value) ->
    typeof value == 'object'
  
  @isFunction: (value) ->
    typeof value == 'function'
    
  @hasAttribute: (obj,attr) ->
    obj? and attr? and @isObject(obj) and obj[attr]? and obj[attr]
    
  @sleep = (s,callback) -> 
    ms = s*1000
    window['_sleeping'] = setTimeout(callback,ms)


  # --- tools and facilities

  @ctrl_c: (text) ->
    textArea = document.createElement('textarea')
    textArea.style.position = 'fixed'
    textArea.style.top = 0
    textArea.style.left = 0
    textArea.style.width = '2em'
    textArea.style.height = '2em'
    textArea.style.padding = 0
    textArea.style.border = 'none'
    textArea.style.outline = 'none'
    textArea.style.boxShadow = 'none'
    textArea.style.background = 'transparent'
    textArea.value = text
    document.body.appendChild(textArea)
    textArea.select();
    try 
      successful = document.execCommand('copy')
      @ctrl_v = text
    document.body.removeChild(textArea)
    successful


  @doAfter: (ds, callback, timer = '_pinkman_doAfter') ->
    window[timer] = window.setTimeout(callback, ds*100)

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
        f(args...)

  @json2url: (url,opts) ->
    if url?
      if opts? and typeof opts == 'object'
        params = []
        keysCount = Object.keys(opts).length
        if keysCount >= 1
          params.push("#{k}=#{v}") for k,v of opts
          url = url + '?'
          url = url + params.join('&')
      return(url)
    else
      ''

  @objToArray: (obj) ->
    i = 0
    a = []
    for k,v of obj
      a.push {index: i, key: k, value: v}
      i = i+1
    a

  # i hated that i had to do this
  @unescape: (string) ->
    if Pinkman.isString(string)
      map = { '&amp;': '&', '&lt;': '<', '&gt;': '>', '&quot;': '"', '&#39;': "'", '&#x2F;': '/', '&#x60;': '`', '&#x3D;': '=' }
      keys = []
      keys.push("(?:#{k})") for k,v of map
      window.regexp = new RegExp(keys.join('+|') + '+','gm')
      string.replace regexp, (match) ->
        map[match]
    else
      ''
    
  
  @calledFunctions = []

  # --- Scope

  @scope: (obj) ->
    if obj?
      scope = @getSelfScope(obj)
      scope = @getClassScope(obj) unless scope?
      scope = @getAppScope(obj) unless scope?
      scope

  @hasScope: (obj) ->
    obj? and (@hasSelfScope(obj) or @hasClassScope(obj) or @hasAppScope(obj))

  @hasSelfScope: (obj) ->
    obj? and obj.scope? and obj.scope != ''

  @hasClassScope: (obj) ->
    obj? and obj.constructor.scope? and obj.constructor.scope != ''

  @hasAppScope: (obj) ->
    obj? and ((obj.pinkmanType == 'collection' and AppCollection? and AppCollection.scope? and AppCollection != '') or (obj.pinkmanType == 'object' and AppObject? and AppObject.scope? and AppObject.scope != ''))

  @getSelfScope: (obj) ->
    obj.scope if @hasSelfScope(obj)

  @getClassScope: (obj) ->
    obj.constructor.scope if @hasClassScope(obj)

  @getAppScope: (obj) ->
    if typeof obj == 'object' and obj.pinkmanType == 'collection' and AppCollection? and AppCollection.scope?
      AppCollection.scope
    else if typeof obj == 'object' and obj.pinkmanType == 'object' and AppObject? and AppObject.scope?
      AppObject.scope
  
  # ready: same as jquery document ready
  @ready: (callback) ->
    $(document).ready(callback)
    
  # --- Ajax

  @ajax: 
    
    request: (options) ->
      if options.url?
        ajax = jQuery.ajax options.url,
            beforeSend: (xhr) -> 
              xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
            type: options.type
            dataType: 'json'
            data: options.data
        ajax.done (response) =>
          if response? and response.errors?
            options.error(this) if options.error? and typeof options.error == 'function'
          else
            options.success(response) if options.success? and typeof options.success == 'function'
            
          options.complete(response) if options.complete? and typeof options.complete == 'function'
          return(true)
      else
        return false

    get: (options) ->
      options.type = 'GET'
      @request(options)

    post: (options) ->
      options.type = 'POST'
      @request(options)

    put: (options) ->
      options.type = 'PUT'
      @request(options)

    patch: (options) ->
      options.type = 'PATCH'
      @request(options)

    delete: (options) ->
      options.type = 'DELETE'
      @request(options)

    file: (options) ->
      if options.url?
        ajax = jQuery.ajax options.url,
            beforeSend: (xhr) -> 
              xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
            xhr: ->
              myXhr = $.ajaxSettings.xhr()
              myXhr.upload.addEventListener 'progress', (e) ->
                  if e.lengthComputable
                    options.progress e.loaded/e.total if options.progress?
                , false
              myXhr.addEventListener 'progress', (e) ->
                  if e.lengthComputable
                    options.progress e.loaded/e.total if options.progress?
                , false
              return myXhr
            type: "POST"
            dataType: 'json'
            data: options.data
            processData: false
            contentType: false
        ajax.done (response) =>
          if response? and response.errors?
            options.error(this) if options.error? and typeof options.error == 'function'
            return false
          else
            options.success(response) if options.success? and typeof options.success == 'function'
          options.complete(response) if options.complete? and typeof options.complete == 'function'
        return this
      else
        return false

    upload: (options...) ->
      @file(options...)

window.$p = Pinkman

Pinkman.ready ->
  unless Pinkman.pathname?
    Pinkman.pathname = window.location.pathname
    Pinkman.pathname = Pinkman.pathname + '/' if Pinkman.pathname.charAt([Pinkman.pathname.length] - 1) != "/"