class window.PinkmanCollection extends window.PinkmanCommon

  @pinkmanType: 'collection'
  @privateAttributes: ['isPink','isCollection','pinkey','config','pinkmanType']
  
  config:
    memberClass: PinkmanObject

  constructor: () ->

    @isPink = true
    @isCollection = true
    @pinkmanType = 'collection'
    
    @collection = []
    @pinkey = Pinkman.all.length + 1

    Pinkman.collections.push(this)
    Pinkman.all.push(this)

  # Desc: return an array of all members
  # this behaviour makes life easier... trust me
  attributes: ->
    return @collection

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

  # Desc: receive a function and apply it to all members
  # tip: you can chain functions. Example: collection.each(transform).first()
  each: (transformation='') ->
    if transformation? and typeof transformation=='function' 
      transformation(o) for o in @collection
    return this

  # Desc: returns a new collection of all members that satisfies a criteria (criteria(obj) returns true)
  select: (criteria,callback='') ->
    selection = new @constructor
    @each (object) ->
      selection.push(object) if criteria(object)
    callback(selection) if typeof callback == 'function'
    return(selection)

  # Desc: insert in last position
  push: (arg) ->
    if Pinkman.isArray(arg)
      @fetchFromArray(arg)
    else
      @pushIndividually(arg)

  pushIndividually: (object) ->
    if typeof object == 'object'
      object = @beforeInsertionPrep(object)
      unless @include(object)
        @collection.push(object)
        object.collections.push(this) if object.isObject and object.collections? and not object.collections.include(this)

  # Desc: insert in first position
  unshift: (object) ->
    if object? and Pinkman.isArray(object)
      for item in object
        @unshiftIndividually(item)
    else if typeof object == 'object' and object.isPink and not @include(object)
      @collection.unshift(object)
      object.collections.unshift(this) if object.isObject and object.collections? and not object.collections.include(this)

  unshiftIndividually: (object) ->
    if typeof object == 'object'
      object = @beforeInsertionPrep(object)
      unless @include(object)
        @collection.unshift(object)
        object.collections.push(this) if object.isObject and object.collections? and not object.collections.include(this)

  beforeInsertionPrep: (object) ->
    unless object.isPink
      pinkObject = @new()
      pinkObject.assign(object)
      object = pinkObject
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
    for object in @collection
      @select (matching) ->
        duplicated.push(matching) if object.pinkey? and (object.pinkey == matching.pinkey) and (object isnt matching)
        duplicated.push(matching) if object.id? and (object.id == matching.id) and (object isnt matching)
    for d in duplicated
      @remove(d)
    return(this)

  # Desc: fetch from array ... T_T

  ############ missing tests from here ################

  fetchFromArray: (array) ->
    for a in array
      object = @beforeInsertionPrep(a)
      # if object already is in this collection, overwrite its values
      if @find(object.id)?
        @find(object.id).assign(object.attributes())
      # else, inserts it
      else
        @push(object)
    return(this)

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
    @push(object)
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