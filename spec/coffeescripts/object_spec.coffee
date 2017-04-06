class window.Dummy extends PinkmanObject
  config:
    apiUrl: '/api/dummy'

describe 'PinkmanObject', ->

  it 'exists', ->
    expect(PinkmanObject).not.toBe null

  describe 'Subclasses', ->

    it 'Subclass has @pinkmanType == "object"', ->
      expect(Dummy.pinkmanType).toBe 'object'

  describe 'Instances', ->

    it 'Every instance of a PinkmanObject has a unique pinkey (pinkman key / pinkman id)', ->
      a = new PinkmanObject
      b = new Dummy
      expect(a.pinkey).not.toBe null
      expect(b.pinkey).not.toBe null
      expect(a.pinkey).not.toEqual b.pinkey

    it 'is pink', ->
      a = new Dummy
      expect(a.isPink).toBeTruthy

    it 'is in Pinkman.all', ->
      a = new PinkmanObject
      expect(Pinkman.all).toContain a

    it 'is in Pinkman.objects', ->
      a = new PinkmanObject
      expect(Pinkman.objects).toContain a

    it 'has pinkmanType == "object"', ->
      a = new Dummy
      expect(a.pinkmanType).toEqual 'object'

  describe 'Functions', ->
    # scopes a variable 
    a = null
    beforeEach ->
      a = new Dummy
      a.set('a','b')

    it 'assign: receives a js object and assigns its values', ->
      a = new Dummy
      b = {attributeA: 'a', attributeB: 'b'}
      a.assign(b)
      expect(a.attributeA).toEqual 'a'
      expect(a.attributeB).toEqual 'b'

    it 'assign: does not substitute pinkman.objects by js.objects', ->
      a = new Dummy
      a.b = new Dummy
      attributes = {b: {something: 'cool'}}
      a.assign attributes
      expect(a.b.isPink).toBeTruthy
      expect(a.b.something).toBe 'cool'

    it 'assign: does substitute pinkman.object by anything except js.objects', ->
      a = new Dummy
      a.b = new Dummy
      attributes = {b: 'value'}
      a.assign attributes
      expect(a.b.isPink).not.toBeTruthy
      expect(a.b).toBe 'value'      

    it 'attributes: returns a javascript object version', ->
      expect(a.attributes()).toEqual {'a': 'b'}

    it 'attributesKeys: returns a array of keys', ->
      a.set('x','y')
      expect(a.attributesKeys()).toEqual ['a','x']

    it 'attributesKeys: has an alias called keys', ->
      a.set('x','y')
      expect(a.keys()).toEqual a.attributesKeys()

    it 'toString: returns a human readable string', ->
      a = new Dummy
      a.set('a','b')
      expect(a.toString()).toEqual '(Dummy) a: b;'