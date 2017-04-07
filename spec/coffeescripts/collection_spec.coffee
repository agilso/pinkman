 describe 'PinkmanCollection', ->

  it 'exists', ->
    expect(PinkmanCollection).not.toBe null

  class Dummies extends PinkmanCollection
    config:
      apiUrl: '/api/dummies'
      memberClass: Dummy

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
      expect(a.isPink).toBeTruthy()

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

    describe 'Predicate Functions', ->
      it 'include: check if a object is in the collection', ->
        a = new Dummy
        collection.push(a)
        expect(collection.include(a)).toBeTruthy()
        expect(collection.include(object)).toBeFalsy()

      it 'include (id rule): if among the members, someone has the same id of the object passed, include returns true', ->
        a = new Dummy
        b = new Dummy
        c = new Dummy

        a.set('id',1)
        a.set('who','i am a.')
        b.set('id',1)
        b.set('who','i am b! I am not a! I am not really in the collection but I have the same id of "a"! Yes I am a duplicated object.')
        collection.push(a)

        expect(collection.include(a)).toBeTruthy()
        expect(collection.include(b)).toBeTruthy()

      it 'any: returns true iff there is at least one member', ->
        expect(collection.any()).toBeFalsy()
        collection.push(object)
        expect(collection.any()).toBeTruthy()

      it 'any: returns true iff any member satisfies a criteria (criteria(object) is true)', ->
        a = new Dummy
        a.set 'prettyHair', 'yes'
        b = new Dummy
        b.set 'prettyHair', 'no'
        collection.push(a)
        collection.push(b)
        thatIsTrue = collection.any (obj) ->
          obj.prettyHair == 'yes'

        bullshit = collection.any (obj) ->
          obj.prettyEyesAlso == 'yes'
        expect(thatIsTrue).toBeTruthy()
        expect(bullshit).toBeFalsy()

    describe 'Info / Iterators /  Modifiers', ->
     
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

      it 'count: accept a criteria function and returns a count of how many members satisfies it', ->
        a = new Dummy
        a.set 'prettyHair', 'yes'
        b = new Dummy
        b.set 'prettyHair', 'no'
        collection.push(a)
        collection.push(b)
        count = collection.count (obj) ->
          obj.prettyHair == 'yes'
        expect(count).toEqual 1

      it 'each: apply a function to all members', ->
        a = new Dummy
        collection.push(a)
        collection.push(object)
        collection.each (obj) ->
          obj.set('each','transformed')
        for obj in collection.collection
          expect(obj.each).toEqual 'transformed'


    describe 'Inserting elements', ->

      it 'push: insert in last position', ->
        a = new Dummy
        collection.push(a)
        collection.push(object)
        expect(collection.last()).toBe object

      it 'unshift: insert in first position', ->
        a = new Dummy
        collection.unshift(a)
        collection.unshift(object)
        expect(collection.first()).toBe object
        expect(collection.last()).toBe a


    describe 'Retrieving elements', ->

      it 'first: return first object in this collection', ->
        a = new Dummies
        b = new Dummy
        a.push(object)
        a.push(b)
        expect(a.first()).toBe object

      it 'last: return last object in this collection', ->
        a = new Dummies
        b = new Dummy
        a.push(object)
        a.push(b)
        expect(a.last()).toBe b

      it 'get (1st usage format): get by pinkey if arg is a number (similar to getByPinkey function)', ->
        arg = 1 # number
        spyOn collection, 'getByPinkey'
        collection.get(arg)
        expect(collection.getByPinkey).toHaveBeenCalled()

      it 'get (2nd usage format): get by attribute/value if arg is a pair of strings (similar to getBy function)', ->
        arg = ['attribute','value'] # pair of string
        spyOn collection, 'getBy'
        collection.get(arg...)
        expect(collection.getBy).toHaveBeenCalled()

      it 'get (3rd usage format): get by multiples attributes/values of a object (arg is a object) (similar to getByAttributes function)', ->
        arg = {attribute: 'value'} # object
        spyOn collection, 'getByAttributes'
        collection.get(arg)
        expect(collection.getByAttributes).toHaveBeenCalled()

      it 'find: get an element by id', ->
        a = new Dummy
        a.set('id',1)
        b = new Dummy
        collection.fetchFromArray([a,b])
        expect(collection.find(1)).toBe a

      it 'getByPinkey: get an element by pinkey', ->
        a = new Dummy
        b = new Dummy
        collection.fetchFromArray([a,b])
        expect(collection.getByPinkey(b.pinkey)).toBe b

      it 'getBy: find the first element that matches (element.attribute = value)', ->
        a = new Dummy
        a.set('attribute','random')
        b = new Dummy
        b.set('attribute','random')

        collection.fetchFromArray([a,b,object])
        expect(collection.getBy('attribute','random')).toBe a

      it 'getByAttributes: find the first element that matches (multiple keys & values version of getBy)', ->
        a = new Dummy
        a.set('attribute','random')
        a.set('prettyHair','yes')
        
        b = new Dummy
        b.set('attribute','random')
        b.set('prettyHair','no')

        collection.fetchFromArray([a,b,object])
        expect(collection.getByAttributes({'attribute': 'random','prettyHair': 'yes'})).toBe a

      it 'select: select/collect every member who satisfies a criteria (criteria(object) is true)', ->
        a = new Dummy
        a.set 'prettyHair', 'yes'
        
        b = new Dummy
        b.set 'prettyHair', 'no'

        collection.push(a)
        collection.push(b)
        selection = collection.select (obj) ->
          obj.prettyHair == 'yes'
        expect(selection.include(a)).toBeTruthy()
        expect(selection.include(b)).toBeFalsy()

      it 'select: accept a callback for the selection', ->
        a = new Dummy
        a.set 'prettyHair', 'yes'
        b = new Dummy
        b.set 'prettyHair', 'no'
        collection.push(a)
        collection.push(b)
        collection.select (obj) ->
          obj.prettyHair == 'yes'
        , (selection) ->
          expect(selection.include(a)).toBeTruthy()
          expect(selection.include(b)).toBeFalsy()

    describe 'Removing elements', ->

      it 'pop: removes from last position and returns it', ->
        a = new Dummy
        collection.push(a)
        collection.push(object)
        expect(collection.pop()).toBe object
        expect(collection.include(object)).toBeFalsy()
        expect(collection.include(a)).toBeTruthy()

      it 'shift: removes from first position and returns it', ->
        a = new Dummy
        collection.push(a)
        collection.push(object)
        expect(collection.shift()).toBe a
        expect(collection.include(a)).toBeFalsy()      
        expect(collection.include(object)).toBeTruthy()      

      it 'remove: remove a object', ->
        collection.push(object)
        expect(collection.include(object)).toBeTruthy()
        collection.remove(object)
        expect(collection.include(object)).toBeFalsy()

      it 'remove: count subtracts 1', ->
        collection.push(object)
        expect(collection.count()).toEqual 1
        collection.remove(object)
        expect(collection.count()).toEqual 0

      it 'removeBy: remove the first object that matches', ->
        removed = new Dummy
        removed.set('yaba','dabadoo')
        object.set('yaba','no-scooby-here')
        collection.push(removed)
        collection.push(object)
        collection.removeBy('yaba','dabadoo')
        expect(collection.include(removed)).toBeFalsy()
        expect(collection.include(object)).toBeTruthy()

      it 'removeAll: remove everyone', ->
        a = new Dummy
        collection.push(a)
        collection.push(object)
        expect(collection.include(a)).toBeTruthy()
        expect(collection.include(object)).toBeTruthy()

        expect(collection.removeAll()).toBeTruthy()
        expect(collection.any()).toBeFalsy()
        expect(collection.count()).toEqual 0
        expect(collection.include(a)).toBeFalsy()
        expect(collection.include(object)).toBeFalsy()