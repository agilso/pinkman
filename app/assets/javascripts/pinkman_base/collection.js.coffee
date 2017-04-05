class window.PinkmanCollection

  attributes: ->
    return @collection

  each: (transformation='') =>
    if transformation? and typeof transformation=='function' then (transformation(o) for o in @collection) else this

  @renderArray: (array,templateId, target, callback = "") ->
    # saves rendering information to rerender later
    collection = new this
    collection.collection = array
    $("#" + target).html(Pinkman.render template: templateId, object: collection)
    callback(collection) if typeof callback == "function"
    true

  @_collectionsCount = 0
   
  @getCount: ->
    return @_collectionsCount

  @increaseCount: ->
    @_collectionsCount++

  constructor: () ->
    # console.log arguments.callee.caller.caller
    @pinkmanType = "collection"
    @type = 'main'
    @collection = []
    @pinkey = PinkmanGlue.count()
    PinkmanGlue.increaseCount() 
    PinkmanGlue.all.push(this)
    @collectionId = PinkmanCollection.getCount()
    PinkmanCollection.increaseCount() 
    PinkmanGlue.collections.push(this)


  set: (attr,value, callback = "" ) ->
    if attr? and value?
      this[attr] = value
      callback(this) if typeof callback == "function"
      return true
    else 
      return false

  pushToRenderQueue: (options) ->
    @renderQueue = [] unless @renderQueue?
    options.reRendering = no

    # check if this exactly options is already in the renderQueue
    alreadyPresent = false
    for obj in @renderQueue
      value = true
      for k,v of obj
        if typeof(obj[k]) == 'function' and typeof(options[k]) == 'function'
          value = false if obj[k].toString().replace(/\s/g, '') != options[k].toString().replace(/\s/g, '')
        else if obj[k] != options[k]
          value = false 
        else
      alreadyPresent = true if value

    # insert options to renderQueue if it isn't already there
    @renderQueue.push options unless alreadyPresent

  clearRenderQueue: () ->
    @renderQueue = []

  apiUrl: () ->
    @config.apiUrl

  removeAll: () ->
    @collection = []

  getByAttributes: (obj) ->
    if @any()
      for o in @collection
        match = true
        for k,v of obj
          match = false if o[k]!=v 
        return(o) if match
    else
      return null

  getBy: (attr, value) ->
    if @any()
      for obj in @collection
        return obj if obj[attr]==value
    else
      return null

  get: (id) ->
    return @getBy("id",id)

  next: (obj) ->
    i = @collection.indexOf obj
    @collection[i+1]

  prev: (obj) ->
    i = @collection.indexOf obj
    @collection[i-1]

  removeBy: (attr, value) ->
    obj = this.getBy(attr,value)
    index = @collection.indexOf obj
    obj.removeCollection @collectionId
    @collection.splice(index,1)

  remove: (obj) ->
    obj.removeCollection @collectionId
    i = @collection.indexOf obj
    @collection.splice(i,1)

  logKeys: () ->
    for obj in @collection
      console.log obj.pinkey


  push: (obj) ->
    if typeof(obj) == "object"
      @collection.push obj 
      obj.addCollection(@collectionId)

  unshift: (obj) ->
    if typeof(obj) == "object"
      @collection.unshift obj 
      obj.addCollection(@collectionId)

  any: (criteria = "") ->
    # Se houver elementos na coleção...
    if @collection? and @collection.length >= 1      
      # Se houver um critério, atribui verdadeiro se o critério se verificar para algum objeto.
      if typeof criteria == "function"
        valor = false
        for o in @collection
          valor = true if criteria(o)
        return valor
      # Se não houver uma função critério, retorna verdadeiro porque há elementos na coleção
      else
        return true
    # Se não houver elementos, retorna falso (repare que isto independe de critério)
    else
      return false

  include: (obj) ->
    if this.any()
      sameObject = false
      for o in @collection
        sameKeysAndValues = true
        for k of o
          sameKeysAndValues = false if o[k] != obj[k]
        sameObject = true if sameKeysAndValues
      return sameObject
    else
      return false

  uniq: (callback="") ->
    @duplicatedRemoved = 0
    for objA in @collection
      d = @select (o) =>
        if o? and objA? and o.id? and objA.id?
          o.id == objA.id and @collection.indexOf(o) != @collection.indexOf(objA) 
      for duplicated in d
        @remove(duplicated)
        @duplicatedRemoved = @duplicatedRemoved + 1
    if typeof callback == 'function'
      return callback(this)

  merge: (anotherCollection) ->
    @fetchFromArray(anotherCollection.collection)

  select: (criteria = "") ->
    vector = []
    if typeof criteria == 'function'
      for obj in @collection
        vector.push(obj) if criteria(obj)
    c = new @constructor
    c.fetchFromArray vector
    return c


  save: () ->
    if this.any()
      for obj in @collection
        obj.save()

  first: (n=1) ->
    if n==1 
      return @collection[0]
    else 
      return @collection[0..(n-1)]

  firstTwo: =>
    @first(2) if @first? and typeof @first == 'function'

  firstThree: =>
    @first(3) if @first? and typeof @first == 'function'

  firstFour: =>
    @first(4) if @first? and typeof @first == 'function'

  firstFive: =>
    @first(5) if @first? and typeof @first == 'function'

  firstSix: =>
    @first(6) if @first? and typeof @first == 'function'

  firstSeven: =>
    @first(7) if @first? and typeof @first == 'function'

  firstEight: =>
    @first(8) if @first? and typeof @first == 'function'

  firstNine: =>
    @first(9) if @first? and typeof @first == 'function'

  firstTen: =>
    @first(10) if @first? and typeof @first == 'function'

  last: (n=1) ->
    if n==1 
      return @collection[@collection.length - 1] 
    else 
      return @collection[(@collection.length - n - 1)..]

  render: (options) ->
    defaultOptions =
      template: null
      target: null
      clearDuplicated: yes
      reRender: yes
      reRendering: no
      callback: ""
      beforeRender: ""
      order: ""
      index: no
      history: null

    # setting options object
    if typeof options == "object" 
      for k,v of defaultOptions
        options[k] = defaultOptions[k] unless options[k]?
    else
      options = defaultOptions


    if options.template? and options.target?

      # beforeRender callbacks
      options.beforeRender(this) if typeof options.beforeRender == "function"

      # removing duplicated
      @uniq() if options['clearDuplicated']
      
      # Compiling template
      content = Pinkman.render template: options.template, object: this      
      
      # index 
      @makeIndex() if options.index and @makeIndex? and (typeof @makeIndex == "function")

      # history
      if window? and history? and options.history? and !options.reRendering
        unless Pinkman.pathname?
          Pinkman.pathname = window.location.pathname
          Pinkman.pathname = Pinkman.pathname + '/' if Pinkman.pathname.charAt([Pinkman.pathname.length] - 1) != "/"
        options.reRender = yes
  
        history.pushState({ pinkey: @pinkey }, "", (Pinkman.pathname + options.history)) 
        Pinkman.popstate()

      # saves rendering information to rerender later
      @pushToRenderQueue(options) if options.reRender

      # sort
      @sortBy(options.order.by,options.order.direction) if @count() > 1 and options.order? and typeof options.order == "object"

      # rendering
      $("#" + options.target).html(content)

      # checks and sync select options with the pinkman object
      $("##{options.target} select").each (i,el) ->
        obj = Pinkman.get($(el).data('pinkey'))
        $(el).find("option[value='#{obj[$(el).attr('name')]}']").attr('selected','selected')

      options.callback(this) if typeof options.callback == "function"
    true

  reRender: (callback = "") ->
    if @renderQueue and @renderQueue.length >= 1
      @clearCycle()
      for options in @renderQueue
        options.reRendering = yes
        @render(options)
      callback(this) if typeof callback == "function"

  sortBy: (key,order = "asc") ->
    array = @collection.sort (a,b) -> 
      if typeof a[key] == "string" and typeof b[key] == "string" 
        if a[key].toLowerCase() >= b[key].toLowerCase() 
          return 1
        else
          return -1
      else
        if a[key] >= b[key] 
          return 1 
        else 
          return -1
    @collection = if order.toLowerCase()=="asc" then array else array.reverse()

  search: (query,callback='') ->
    @type = 'search'
    @query = query
    @searchCallback = callback
    @removeAll()
    Pinkman.ajax.get
      url: '/' + @apiUrl() + "/search?query=#{query}"
      complete: (response) =>
        for objAttrs in response
          obj = @config.memberClass()
          obj.assign objAttrs
          @push(obj)
        @searchCallback(this) if typeof callback == 'function'

  fetchFromArray: (array) ->
    for obj in array
      pinkmanObject = @config.memberClass()
      pinkmanObject.assign(obj)
      unless @include(pinkmanObject) or @getBy('id',pinkmanObject.id)?
        @push(pinkmanObject) 
      else if @getBy('id',pinkmanObject.id)?
        @getBy('id',pinkmanObject.id).assign(pinkmanObject.attributes())


  assign: (array) ->
    @fetchFromArray(array)


  fetchFromUrl: (url,callback = "") ->
    # console.log @
    ajax = jQuery.ajax "/" + url,
      type: "GET"
      dataType: 'json'
    ajax.done (response) =>
      # console.log response
      if response.errors?
        # console.log 'deu erro'
        @errors = response.errors
        return false
      else
        # console.log 'deu bom'
        @fetchFromArray(response)
        @emptyResponse = response.length == 0

        if typeof callback == "function"
          callback(this)
      return this

  fetch: (callback = "") ->
    if typeof callback == "function"
      @fetchFromUrl @apiUrl(), (collection) ->
        callback(collection)
    else
      @fetchFromUrl @apiUrl()

  fetchFrom: (actionUrl,id,callback = "") ->
    if id?
      if typeof callback == "function"
        return @fetchFromUrl @apiUrl() + "/" + actionUrl + "/" + id, (collection) ->
          callback(collection)
      else
        return @fetchFromUrl @apiUrl() + "/" + actionUrl + "/" + id
    else
      return false

  fetchMore: (n=10,callback='') ->
    switch @type
      when 'main'
        @fetchFromUrl @apiUrl() + "?limit=#{n}&offset=#{@count()}", callback
      when 'archive'
        @fetchFromUrl(@apiUrl() + "/archive?limit=#{n}&offset=#{@count()}",callback)
      when 'search'
        @fetchFromUrl(@apiUrl() + "/search?query=#{@query}&limit=#{n}&offset=#{@count()}",callback)
      else
        console.log "I don't know where to fetch from"

  fetchMoreFrom: (n,actionUrl,id,callback='') ->
    url = @apiUrl() + '/' + actionUrl + "/#{id}?offset=#{@count()}&limit=#{n}"
    @fetchFromUrl(url,callback)

  reload: (callback = "") ->
    if @any()
      for obj in @collection
        obj.reload ->
          @remove(obj) unless obj.id?
      if typeof callback == "function"
        callback(this)

  count: (criteria) ->
    if @any()
      if typeof criteria=="function"
        count = 0
        for obj in @collection
          count++ if criteria(obj)
        return count
      else
        return @collection.length
    else
      return 0

  cycle: (a = "odd" ,b = "even") =>
    @cycleIndex = 0 unless @cycleIndex?
    value = if (@cycleIndex % 2 == 0) then a else b
    @cycleIndex++
    return value

  clearCycle: () =>
    @cycleIndex = 0

  makeIndex: ->
    if @any()
      i = 1
      for obj in @collection
        obj.set("index",i)
        i++
      return true
    else
      return false

  new: =>
    obj = new @config.memberClass
    obj.set('owner',this)
    obj

  pinkfy: (attribute,pinkmanClass,callback = "") ->
    if pinkmanClass.pinkmanType == "collection" and (this[attribute] instanceof Array)
      collection = new pinkmanClass
      for obj in this[attribute]
        pinkmanObject = collection.config.memberClass()
        pinkmanObject.assign(obj)
        collection.push(pinkmanObject)
      this[attribute] = collection
      callback(collection) if typeof callback == "function"
      return this
    else if pinkmanClass.pinkmanType == "object" and (typeof this[attribute] == "object")
      pinkmanObject = new pinkmanClass
      if (this[attribute] instanceof Array) and (this[attribute].length)
        pinkmanObject.assign(this[attribute][0]) 
      else
        pinkmanObject.assign this[attribute]
      this[attribute] = pinkmanObject
      callback(pinkmanObject) if typeof callback == "function"
      return this
    else
      return false


  ten: ->
    if @count() <= 10 then return(@collection[0..] ) else return(@collection[0..9])



  # --- Revisar daqui pra baixo

  refine: (field,query) ->
    if @any()
      collection = @collection
      @collection = []
      @clearCycle()
      if field? and query? and typeof(field) == "string"
        for obj in collection
          if obj[field]? and typeof(obj[field] == "string" ) and (obj[field].toLowerCase().indexOf(query.toLowerCase()) > -1)
            @push obj
      return true
    else
      return false

  dynamicRefine: (query, method) ->
    if typeof method == "function"
      @refine(method(query),query)
    else
      return false

  arrayFilter: (field,query) ->
    if field? and query? and query!="" and (typeof(field) == "string")
      if @any()
        filtered = []
        @clearCycle()
        for obj in @collection
          if obj[field] == query
            filtered.push obj
          else if obj[field]? and (typeof obj[field] == "string") and (obj[field]!="") and (typeof query == "string") and (query!="") and (obj[field].toLowerCase().indexOf(query.toLowerCase()) > -1)
            filtered.push obj
      return filtered
    else
      return false

  filter: (field,query,callback) ->
    if field? and query? and query!="" and (typeof(field) == "string")
      if @any()
        filtered = new this.__proto__.constructor
        @clearCycle()
        for obj in @collection
          if obj[field] == query
            filtered.push obj
          else if obj[field]? and (typeof obj[field] == "string") and (obj[field]!="") and (typeof query == "string") and (query!="") and (obj[field].toLowerCase().indexOf(query.toLowerCase()) > -1)
            filtered.push obj
      callback(filtered) if callback? and typeof callback == 'function'
      return filtered
    else
      return false

  dynamicFilter: (query, method) ->
    if typeof method == "function"
      @filter(method(query),query)
    else
      return false

  shuffle: () ->
    if @any?
      currentIndex = @collection.length

      # // While there remain elements to shuffle...
      while (0 != currentIndex) 
        # // Pick a remaining element...
        randomIndex = Math.floor(Math.random() * currentIndex)
        currentIndex = currentIndex - 1

        # // And swap it with the current element.
        temporaryValue = @collection[currentIndex]
        @collection[currentIndex] = @collection[randomIndex]
        @collection[randomIndex] = temporaryValue

  isPink: true