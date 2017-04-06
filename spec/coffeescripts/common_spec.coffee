describe 'PinkmanCommon', ->

  it 'exists', ->
    expect(PinkmanCommon).not.toBe null

  class Dummy extends PinkmanCommon
    config:
      apiUrl: '/api/dummy'

  it 'apiUrl: returns api url as expected (config object)', ->
    a = new Dummy
    expect(a.apiUrl()).toBe '/api/dummy'

  it 'className: returns a string with the class name', ->
    a = new Dummy
    expect(a.className()).toBe 'Dummy'

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
