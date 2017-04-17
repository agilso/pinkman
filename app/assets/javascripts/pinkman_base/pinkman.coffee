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

  # --- tools and facilities

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

  @calledFunctions = []

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
          if response.errors?
            options.error(this) if options.error? and typeof options.error == 'function'
            return(false)
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

$(document).ready ->
  unless Pinkman.pathname?
    Pinkman.pathname = window.location.pathname
    Pinkman.pathname = Pinkman.pathname + '/' if Pinkman.pathname.charAt([Pinkman.pathname.length] - 1) != "/"