describe 'PinkmanCommon', ->

  class Dummy extends PinkmanCommon
    config:
      api: '/api/dummy'

  describe 'Class Scope/Functions', ->
    it 'exists', ->
      expect(PinkmanCommon).not.toBe null

    it '@isInstance: return true if the object is a instance of this class', ->
      a = new Dummy
      expect(Dummy.isInstance(a)).toBeTruthy()


  it 'api: returns api url as expected (config object)', ->
    a = new Dummy
    expect(a.api()).toBe '/api/dummy/'

  it 'className: returns a string with the class name', ->
    a = new Dummy
    expect(a.className()).toBe 'Dummy'

  it 'isInstanceOf: return true if it is a instance of the passed class', ->
    a = new Dummy
    expect(a.isInstanceOf(Dummy)).toBeTruthy()
  

  it 'set: sets a pair of key and value', ->
    a = new Dummy
    a.set('uhu','bozo')
    expect(a.uhu).toEqual 'bozo'

  it 'set: triggers reRender if watch is true', ->
    a = new Dummy
    spyOn a, 'reRender'
    a.set 'watch', yes
    a.set 'a', 'b'
    expect(a.reRender).toHaveBeenCalled()
