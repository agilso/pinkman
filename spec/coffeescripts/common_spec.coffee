describe 'PinkmanCommon', ->

  class Dummy extends PinkmanCommon
    config:
      api: '/api/dummy'
      
  class Dummy2 extends PinkmanCommon
    config:
      api: '/api/dummy'
      className: 'Custom'
  
  beforeEach ->
    window.a = new Dummy
    
  describe 'Class related functions', ->
    it 'exists', ->
      expect(PinkmanCommon).not.toBe null

    it '@isInstance: return true if the object is a instance of this class', ->
      expect(Dummy.isInstance(a)).toBeTruthy()

  it 'has a pinkey', ->
    expect(a.pinkey).not.toBe null
    
  it 'api: returns api url as expected (config object)', ->
    expect(a.api()).toBe '/api/dummy/'

  it 'className: returns a string with the class name', ->
    expect(a.className()).toBe 'Dummy'
  
  it 'className: you can set a custom class name through the class config object', ->
    b = new Dummy2
    expect(b.className()).toBe 'Custom'
    
  it 'isInstanceOf: return true if it is a instance of the passed class', ->
    expect(a.isInstanceOf(Dummy)).toBeTruthy()
  
  it '_listening attr is true by default', ->
    expect(a._listening).toBeTruthy()

  describe 'Set Function', ->
    
    it 'sets a pair of key and value', ->
      a.set('uhu','bozo')
      expect(a.uhu).toEqual 'bozo'

    it 'is chainable', ->
      expect(a.set('anything','doesnt matter')).toBe a
    
    it 'accepts a callback function', ->
      a.lol = ->
        'lol'
      spyOn a, 'lol'
      a.set('a','b',a.lol)
      expect(a.lol).toHaveBeenCalled()
    
  describe 'Syncing', ->
    beforeEach ->
      jasmine.clock().install()
    
    afterEach ->
      jasmine.clock().uninstall()
      
    it 'set function triggers sync at least once', ->
      spyOn a, 'sync'
      a.set('lol','a')
      jasmine.clock().tick(10)
      expect(a.sync).toHaveBeenCalled()
    
    it 'set function waits a while before calling sync', ->
      spyOn a, 'sync'
      for i in [1..200]
        a.set('lol','a')
      jasmine.clock().tick(10)
      expect(a.sync.calls.count()).toEqual(1)
    
    it 'does not sync if not listening', ->
      spyOn a, 'sync'
      a.unwatch()
      a.set('lol','a')
      jasmine.clock().tick(10)
      expect(a.sync).not.toHaveBeenCalled()
    
    it 'watch turns syncing on', ->
      a.watch()
      expect(a._listening).toBeTruthy()
    
    it 'unwatch turns syncing off', ->
      a.unwatch()
      expect(a._listening).toBeFalsy()
    
    it 'sync function: accepts a single attribute'
    
    it 'sync function: syncs every attribute if none is passed'
    
    describe 'Computed Functions', ->
      it '@compute: inserts a function in the syncing queue'
      it 'everytime a attribute is set, calls computed functions'
      it 'everytime a attribute is set, syncs computed functions'
  
  describe 'Unset', ->
    it 'sets an attribute to undefined', ->
      a.set('lol','lol')
      a.unset('lol')
      expect(a.lol).toBe undefined
    
    it 'is chainable', ->
      expect(a.unset('lol')).toBe a
    
    it 'accepts a callback', ->
      a.lol = ->
        'lol'
      spyOn a, 'lol'
      a.unset('a',a.lol)
      expect(a.lol).toHaveBeenCalled()
  
  describe 'Render', ->
    it 'accepts a options object'
    it 'accepts a string object'
    it 'deliver responsability to Pinkman.render function'
    it 'passes itself as the rendering object (to Pinkman.render)'
    it 'calls reRender when called without params'
    it 'has a renderQueue'
    it 'renderFirst: renders first in queue'
    it 'renderLast: renders first in queue'
    it 'reRender: renders everyone in the queue'
    it 'append - write tests'
  
  describe 'Errors', ->
    it 'hasErrorsOn: checks if a attribute has errors'
    it 'addErrors(attr,msg): does exactly what it sugests'
    
    