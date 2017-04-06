 describe 'PinkmanCollection', ->

  it 'exists', ->
    expect(PinkmanCollection).not.toBe null

  class Dummies extends PinkmanCollection
    config:
      apiUrl: '/api/dummies'

  class Dummy extends PinkmanObject
    config:
      apiUrl: '/api/dummies'

  describe 'Subclasses', ->

    it 'Subclass has @pinkmanType == "collection"', ->
      expect(Dummies.pinkmanType).toBe 'collection'

  describe 'Instances', ->

    it 'Every instance has a unique pinkey (pinkman key / pinkman id)', ->
      a = new PinkmanCollection
      b = new Dummies
      expect(a.pinkey).not.toBe null
      expect(b.pinkey).not.toBe null
      expect(a.pinkey).not.toEqual b.pinkey

    it 'is pink', ->
      a = new Dummies
      expect(a.isPink).toBe true

    it 'is in Pinkman.all', ->
      a = new PinkmanCollection
      expect(Pinkman.all).toContain a

    it 'is in Pinkman.objects', ->
      a = new PinkmanCollection
      expect(Pinkman.collections).toContain a
      b = new Dummies
      expect(Pinkman.collections).toContain b

    it 'has pinkmanType == "collection"', ->
      a = new Dummies
      expect(a.pinkmanType).toEqual 'collection'

  describe 'Functions', ->
    # scope variables in this namespace
    collection = null
    object = null

    beforeEach ->
      collection = new Dummies
      object = new Dummy
      object.set('a','b')

    it 'count: return collection size', ->
      expect(collection.count()).toEqual 0
      collection.push(object)
      expect(collection.count()).toEqual 1
      a = new Dummy
      collection.push(a)
      expect(collection.count()).toEqual 2

    it 'size: count alias', ->
      expect(collection.count()).toEqual collection.size()
      collection.push(object)
      expect(collection.count()).toEqual collection.size()
      a = new Dummy
      collection.push(a)
      expect(collection.count()).toEqual collection.size()
    
    it 'length: count alias', ->
      expect(collection.count()).toEqual collection.length()
      collection.push(object)
      expect(collection.count()).toEqual collection.length()
      a = new Dummy
      collection.push(a)
      expect(collection.count()).toEqual collection.length()

    it 'count: accepts a criteria function and returns a count of how many members satisfies it', ->
      a = new Dummy
      a.set 'prettyHair', 'yes'
      b = new Dummy
      b.set 'prettyHair', 'no'
      collection.push(a)
      collection.push(b)
      count = collection.count (obj) ->
        obj.prettyHair == 'yes'
      expect(count).toEqual 1

    it 'first: returns first object in this collection', ->
      a = new Dummies
      b = new Dummy
      a.push(object)
      a.push(b)
      expect(a.first()).toBe object

    it 'last: returns last object in this collection', ->
      a = new Dummies
      b = new Dummy
      a.push(object)
      a.push(b)
      expect(a.last()).toBe b

    it 'push: inserts in last position', ->
      a = new Dummy
      collection.push(a)
      collection.push(object)
      expect(collection.last()).toBe object

    it 'each: apply a function to all members', ->
      a = new Dummy
      collection.push(a)
      collection.push(object)
      collection.each (obj) ->
        obj.set('each','transformed')
      for obj in collection.collection
        expect(obj.each).toEqual 'transformed'
