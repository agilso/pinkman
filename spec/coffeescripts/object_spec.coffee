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
      expect(a.pinkey).toBe 1
      expect(b.pinkey).toBe 2

    it 'is pink', ->
      a = new Dummy
      expect(a.isPink).toBe true

    it 'is in Pinkman.all', ->
      a = new PinkmanObject
      expect(Pinkman.all).toContain a

    it 'is in Pinkman.objects', ->
      a = new PinkmanObject
      expect(Pinkman.objects).toContain a

  describe 'Functions', ->

    it 'apiUrl: returns api url as expected (config object)', ->
      a = new Dummy
      expect(a.apiUrl()).toBe '/api/dummy'

    it 'assign: receives a js object and assigns its values', ->
      a = new Dummy
      b = {attributeA: 'a', attributeB: 'b'}
      a.assign(b)
      expect(a.attributeA).toBe 'a'
      expect(a.attributeB).toBe 'b'

    it 'assign: does not substitute pinkman.object by js.objects', ->
      a = new Dummy
      a.b = new Dummy
      attributes = {b: {something: 'cool'}}
      a.assign attributes
      expect(a.b.isPink).toBe true
      expect(a.b.something).toBe 'cool'

    it 'assign: does substitute pinkman.object by anything except js.objects', ->
      a = new Dummy
      a.b = new Dummy
      attributes = {b: 'value'}
      a.assign attributes
      expect(a.b.isPink).not.toBe true
      expect(a.b).toBe 'value'      

    it 'attributes returns a javascript object version', ->
      a = new Dummy
      a.set('a','b')
      expect(a.attributes()).toEqual {'a': 'b'}

    it 'className: returns a string with the class name', ->
      a = new Dummy
      expect(a.className()).toBe 'Dummy'

