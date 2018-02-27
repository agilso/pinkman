class window.PinkmanCollection extends window.PinkmanCommon

  @pinkmanType = 'collection'
  
  config:
    memberClass: PinkmanObject

  constructor: (args...) ->
    super(args...)
    @isCollection = true
    @pinkmanType = 'collection'
    @collection = []
    Pinkman.collections.push(this)

  # Desc: return an array of all members
  # this behaviour makes life easier... trust me
  attributes: ->
    return @collection

  # Desc: json version of this
  # desc: used in api comunications
  json: ->
    json = []
    @each (object) ->
      json.push(object.json()) if object.isPink and object.json? and typeof object.json == 'function'
    json

  # Desc: sum a certain attribute of every element
  sum: (attr,callback) ->
    if attr?
      if $p.isString(attr)
        v = 0
        @each (obj) ->
          if Pinkman.isNumber(obj[attr])
            v = Number(obj[attr]) + v
          else if obj[attr]?
            v = obj[attr] + v
        , =>
          callback(this, v) if typeof callback == 'function'
        return(v)
      else if $p.isFunction(attr)
        v = 0
        @each (obj) ->
          current = attr(obj)
          if $p.isNumber(current)
            v = Number(current) + v
          else
            v = current + v
        , =>
          callback(this, v) if typeof callback == 'function'
        return(v)
    else
      callback(this,0) if typeof callback == 'function'
      return(0)

  # Desc: collection size
  count: (criteria='') ->
    if criteria? and typeof criteria  == 'function'
      count = 0
      (count++ if criteria(object)) for object in @collection
      count
    else
      @collection.length

  # Desc: Alias for count
  size: (criteria='') ->
    @count(criteria)

  # Desc: Alias for count
  length: (criteria='') ->
    @count(criteria)

  # rails/ruby equivalent: each
  # Desc: receive a function and apply it to all members
  # tip: you can chain functions. Example: collection.each(transform).first()
  each: (transformation='',callback) ->
    if transformation? and typeof transformation=='function' 
      i = 0
      for o in @collection
        i = i+1
        transformation(o)
        callback(this) if (i == @count()) and typeof callback == 'function'
    return this

  # rails/ruby equivalent: where/select
  # Desc: returns a new collection of all members that satisfies a criteria (criteria(obj) returns true)
  # new version: accepts a object to match against the object attributes
  select: (criteria,callback='') ->
    selection = new @constructor
    # function version
    if typeof criteria == 'function'
      @each (object) ->
        selection.push(object) if criteria(object)

    # object version
    else if typeof criteria == 'object'
      @each (object) ->
        value = true
        (value = false if object[k] != v) for k,v of criteria
        if value
          if PinkmanController.isInstance(object) or PinkmanAction.isInstance(object)
            selection.forcePush(object) 
          else
            selection.push(object)
    callback(selection) if typeof callback == 'function'
    return(selection)
  
  # extract(attr): 
  # Desc: returns an array containing the value of "attr" from each member of this collection.
  extract: (attr) ->
    array = []
    @each (o) ->
      array.push(o[attr])
    array
  
  # groupBy(attr,callback)
  # Desc: group collections by attr value
  groupBy: (attr,callback) ->
    obj = new Object
    @each (record) =>
      obj[record[attr]] = new @constructor unless obj[record[attr]]?
      obj[record[attr]].push record
      , ->
      callback(obj) if $p.isFunction(callback)
    return(obj)
  
  # every element of this collection will be substituted by the element of the collection passed
  absorb: (collection, callback) ->
    if typeof collection == 'object' and collection.isPink and collection.isCollection
      @each (obj) =>
        o = collection.find(obj.id)
        if o?
          @remove obj, =>
            @forceUnshift(o)
      , callback
    
  # substitute element a by element b
  substitute: (a,b,callback) ->
    if a? and b?
      @remove(a)
      @push(b)
      callback() if typeof callback == 'function'
    
  # Desc: insert in last position
  push: (arg) ->
    if Pinkman.isArray(arg)
      @pushIndividually(item) for item in arg
      return(@include(arg))
    else
      @pushIndividually(arg)

  # Desc: insert in first position
  unshift: (object) ->
    if Pinkman.isArray(object)
      @unshiftIndividually(item) for item in object
      return(@include(object))
    else
      @unshiftIndividually(object)

  pushIndividually: (object) ->
    if object? and typeof object == 'object' and not @include(object)
      @beforeInsertionPrep object, (object) =>
        @collection.push(object)
        object.collections.push(this) if object.isObject and object.collections?
        return true
    else
      return false

  directPush: (object) ->
    @collection.push(object) unless @include(object)

  forcePush: (object) ->
    @collection.push(object)
    
  directUnshift: (object) ->
    @collection.unshift(object) unless @include(object)

  forceUnshift: (object) ->
    @collection.unshift(object)

  unshiftIndividually: (object) ->
    if object? and typeof object == 'object' and not @include(object)
      @beforeInsertionPrep object, (object) =>
        @collection.unshift(object)
        object.collections.push(this) if object.isObject and object.collections?
        return true
    else
      return false

  beforeInsertionPrep: (object,callback='') ->
    unless object.isPink
      pinkObject = @new()
      pinkObject.assign(object)
      object = pinkObject
    callback(object) if typeof callback == 'function'
    return(object)
         
  # Desc: removes from last position and returns it
  pop: ->
    @remove(@last())

  # Desc: removes from first position and returns it
  shift: ->
    @remove(@first())

  # Desc: remove a object from the collection
  remove: (object,callback) ->
    if typeof object == 'object' and object.id? and (a = @find(object.id))?
      i = @collection.indexOf a
      @collection.splice(i,1)
      value = a
    else
      i = @collection.indexOf object
      @collection.splice(i,1)
      value = object
    callback(this) if typeof callback == 'function'
    return(value)

  # Desc: remove the first object that matches
  removeBy: (attribute,value) ->
    if attribute? and value?
      @remove(@getBy(attribute,value))

  # Desc: remove everyone from this collection
  removeAll: ->
    if @any()
      @remove(@first())
      @removeAll()
    else
      return(true)

  # Desc: return true if object is in this collection and false if anything else.
  # Also accepts an array as argument. Return true if every element is in the collection
  include: (args) ->
    if args? and Pinkman.isArray(args)
      value = true
      for item in args
        value=false unless @include(item)
      return(value)
    else if args? and typeof args == 'object' 
      if args.id?
        @any (o) ->
          args.id == o.id
      else
        @collection.indexOf(args) isnt -1
    else
      false


  firstOrInitialize: (args...) ->
    collection = @select(args...)
    if collection.any()
      collection.first()
    else
      @forceNew(args...)
    
  forceNew: (args...)->
    obj = new (@config.memberClass)
    obj.initialize(args...)
    @push(obj)
    obj
    
  first: (n=1) ->
    if n==1 
      return @collection[0]
    else 
      return @collection[0..(n-1)]

  last: (n=1) ->
    if n==1 
      return @collection[@collection.length - 1] 
    else 
      return @collection[(@collection.length - n - 1)..]

  # Desc: return trues if has at least one member. If a criteria is specificied, returns true if at least one member satisfies it.
  any: (criteria='') ->
    if criteria? and (typeof criteria == 'function' or typeof criteria == 'object')
      @select(criteria).count() > 0
    else
      @count() > 0
  
  # Desc: exact opposite of any. Return trues if not a single members is found.
  empty: (args...) ->
    !@any(args...)

  # Desc: return the first object that matches
  getBy: (attribute, value,callback) ->
    if attribute? and value?
      object = new Object
      object[attribute] = value
      return(@getByAttributes(object,callback))

  # Desc: return the first that matches
  getByAttributes: (object,callback) ->
    if object? and typeof object == 'object' and @any()
      for member in @collection
        match = true
        for key,value of object
          match = false if member[key]!=value 
        if match
          callback(member) if typeof callback == 'function'
          return(member) 
    else
      return null

  # Desc: get by pinkey
  getByPinkey: (pinkey) ->
    @getBy('pinkey',pinkey)

  # Desc: sinthetize getByPinkey, getBy, and getByAttributes in one method
  get: (args...) ->
    if args.length > 0
      if Pinkman.isNumber(args[0])
        @getByPinkey(args[0])
      else if args.length == 2
        @getBy(args...)
      else if typeof args[0] == 'object'
        @getByAttributes(args[0])
  
  # Desc: find by id
  find: (id,callback) ->
    if id?
      object = @getBy('id',id,callback)
      return(object)

  # Desc: return the next (after) object
  next: (object) ->
    i = @collection.indexOf object
    @collection[i+1]

  # Desc: return the previous (before) object
  prev: (object) ->
    i = @collection.indexOf object
    @collection[i-1]

  # Desc: log every member pinkey in the console
  logPinkeys: () ->
    @each (object) ->
      console.log object.pinkey

  # Desc: removes duplicated records (same id or same pinkey)
  uniq: (callback='') ->
    duplicated = []
    @each (object) =>
      @each (matching) ->
        duplicated.push(matching) if object.pinkey? and (object.pinkey == matching.pinkey) and (object isnt matching)
        duplicated.push(matching) if object.id? and (object.id == matching.id) and (object isnt matching)
    for d in duplicated
      @remove(d)
    return(this)

  # Desc: fetch from array ... T_T
  fetchFromArray: (array) ->
    for a in array
      object = @beforeInsertionPrep(a)
      # if object already is in this collection, overwrite its values
      if object? and @find(object.id)?
        @find(object.id).assign(object.attributes())
      # else, inserts it
      else
        @push(object)
    return(this)

  # Desc: fetch from array alias
  assign: (array...) ->
    @fetchFromArray(array...)

  # Desc: merges this collection with another
  merge: (collection) ->
    if Pinkman.isArray(collection)
      @fetchFromArray(collection)
    else if typeof collection == 'object' and collection.isPink and collection.isCollection
      @fetchFromArray(collection.collection)

  # Desc: returns a new object associated with this collection
  new: (attributes) ->
    if @_new? and not @_new.id?
      @_new
    else
      @_new = new (@config.memberClass)
      @_new.initialize(attributes)
      @_new

  # Desc: reload every object in this collection
  reload: (callback='') ->
    if @any()
      @each (object) =>
        if object.id?
          object.reload (object) =>
            if object.pinkey == @last().pinkey and callback == 'function'
              callback(this)
  
  # Desc: create a index for objects 
  makeIndex: ->
    if @any()
      i = 1
      for object in @collection
        object.set("index",i)
        i++
      return true
    else
      return false

  # Desc: sort by a given key and order
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
    return(this)

  # Desc: exactly what it suggests
  shuffle: () ->
    if @any()
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

  rand: (n) ->
    if @any()
      rand = new @constructor
      currentIndex = Math.min(n,@count())

      # // While there remain elements to shuffle...
      while (0 != currentIndex) 
        # // Pick a remaining element...
        randomIndex = Math.floor(Math.random() * @count())
        currentIndex = currentIndex - 1
        rand.forcePush(@collection[randomIndex])
      
      if rand.count() == 1
        return(rand.first())
      else
        return(rand)
    
  # Desc: filters collection whose attribute matches the query
  filter: (attribute,query,callback) ->
    if attribute? and query? and query!="" and (typeof(attribute) == "string")
      if @any()
        filter = new @constructor
        for obj in @collection
          if obj[attribute] == query
            filter.push obj
          else if obj[attribute]? and (typeof obj[attribute] == "string") and (obj[attribute]!="") and (typeof query == "string") and (query!="") and (obj[attribute].toLowerCase().indexOf(query.toLowerCase()) > -1)
            filter.push obj
      callback(filter) if callback? and typeof callback == 'function'
      return filter
    else
      return false

  # --- Ajax related --- #

  # Desc: Fetch records from API_URL
  # request:  get /api/API_URL/
  # in rails: api::controller#index
  fetch: (callback = '') ->
    @fetchFromUrl url: @api(), callback: callback      
  
  # Desc: Fetch records from another action of this model api
  # request:  get /api/API_URL/:action/#id
  # in rails: api::controller#action

  # Example: fetching all orders of a user
  # coffee: orders.fetchFrom 'user', user.id
  # api::controler#order: render json: User.find(params[:id]).orders.to_json
  fetchFrom: (action,id,callback) ->
    if action? and id?
      @fetchFromUrl
        url: @api() +  "#{action}/#{id}"
        callback: callback
    else
      return false

  # Desc: Fetch records from URL
  # request:  get /api/API_URL/
  fetchFromUrl: (options) ->
    if options? and typeof options == 'object' and options.url?
      if Pinkman.hasScope(this)
        options.params = new Object unless options.params?
        options.params.scope = Pinkman.scope(this)

      @doneFetching = null
      @fetchingFrom = options.url
      
      Pinkman.ajax.get
        url: Pinkman.json2url(options.url,options.params) 
        complete: (response) =>
          if response?
            [@errors, @error] = [response.errors, response.error] if response.errors? or response.error?
            
            if options.params? and options.params.limit?
              @doneFetching = response.length < options.params.limit
            else
              @doneFetching = response.length == 0
            
            # separate recent when this collection is already populated
            @_recent = new this.constructor

            if response.length > 0
              @_recent.fetchFromArray(response) 
              @fetchFromArray(response)

          @doneFetching = true unless response?
          options.callback(this) if options.callback? and typeof options.callback == 'function'
      return(this)

  # Desc: Fetch next records from last fetched URL or main API_URl
  # request:  get /api/API_URL/?offset="COLLECTION_SIZE"&limit=n
  # in rails: api::controller#index
  fetchMore: (n=10,callback='') ->
    unless @doneFetching
      if @fetchingFrom?
        @fetchFromUrl
          url: @fetchingFrom
          params:
            limit: n
            offset: @count()
          callback: callback
      else
        @fetchFromUrl 
          url: @api()
          params:
            limit: n
            offset: @count()
          callback: callback

  # Desc: Fetch next n records from a action
  # request:  get /api/API_URL/:action/?offset="COLLECTION_SIZE"&limit=n
  # in rails: api::controller#action
  fetchMoreFrom: (n,action,id,callback='') ->
    @fetchFromUrl {url: @api() + "#{action}/#{id}", params: {limit: n, offset: @count()}, callback: callback}

  # Desc: Connect to api to search in this model a query
  # request:  get /api/API_URL/search?query=YOUR_QUERY
  # in rails: api::controller#search
  # assume models to have a Model.search("YOUR_QUERY") method.
  search: (query,callback='') ->
    @removeAll()
    @fetchFromUrl { url: @api() + 'search', params: {query: query}, callback: callback }

window.Pinkman.collection = window.PinkmanCollection