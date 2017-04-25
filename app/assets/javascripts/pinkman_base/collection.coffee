class window.PinkmanCollection extends window.PinkmanCommon

  @pinkmanType = 'collection'
  
  config:
    memberClass: PinkmanObject

  constructor: () ->

    @isPink = true
    @isCollection = true
    @pinkmanType = 'collection'
    
    @collection = []
    @pinkey = Pinkman.all.length

    Pinkman.collections.push(this)
    Pinkman.all.push(this)

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
  each: (transformation='') ->
    if transformation? and typeof transformation=='function' 
      transformation(o) for o in @collection
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
        selection.push(object) if value

    callback(selection) if typeof callback == 'function'
    return(selection)

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
  remove: (object) ->
    if object?
      i = @collection.indexOf object
      @collection.splice(i,1)
      return object

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
  # Also accepts an array as argument. Return true if 
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
    if criteria? and typeof criteria == 'function'
      @select(criteria).count() > 0
    else
      @count() > 0

  # Desc: return the first object that matches
  getBy: (attribute, value) ->
    if attribute? and value?
      object = new Object
      object[attribute] = value
      return(@getByAttributes(object))

  # Desc: return the first that matches
  getByAttributes: (object) ->
    if object? and typeof object == 'object' and @any()
      for member in @collection
        match = true
        for key,value of object
          match = false if member[key]!=value 
        return(member) if match
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
  find: (id) ->
    if id?
      object = @getBy('id',id)
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
    object = new (@config.memberClass)
    object.initialize(attributes)
    object

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

  # Desc: exactly what it suggests
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

  # Desc: filters collection whose attribute matches the query
  filter: (attribute,query,callback) ->
    if attribute? and query? and query!="" and (typeof(attribute) == "string")
      if @any()
        filter = new @constructor
        for obj in @collection
          if obj[attribute] == query
            filter.push obj
          else if obj[attribute]? and (typeof obj[attribute] == "string") and (obj[attribute]!="") and (typeof query == "string") and (query!="") and (obj[field].toLowerCase().indexOf(query.toLowerCase()) > -1)
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
      @fetchingFrom = options.url
      Pinkman.ajax.get
        url: Pinkman.json2url(options.url,options.params) 
        complete: (response) =>
          if response.errors? or response.error?
            [@errors, @error] = [response.errors, response.error]
            if response.errors? then (throw new Error('Oh no... I could not fetch your records, bitch. (jk... about the "bitch" part)')) else (throw new Error(response.error))
            return false
          else
            @fetchFromArray(response).emptyResponse = response.length == 0
            options.callback(this) if options.callback? and typeof options.callback == 'function'
      return(this)

  # Desc: Fetch next records from last fetched URL or main API_URl
  # request:  get /api/API_URL/?offset="COLLECTION_SIZE"&limit=n
  # in rails: api::controller#index
  fetchMore: (n=10,callback='') ->
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
    @fetchFromUrl { url: @api(), params: {query: query}, callback: callback }

window.Pinkman.collection = window.PinkmanCollection