class window.PinkmanStates extends Pinkman.collection
  config:
    className: 'PinkmanStates'
    memberClass: ->
      return (new PinkmanState)

Pinkman.states = new PinkmanStates

class window.PinkmanState extends Pinkman.object
  config:
    className: 'PinkmanState'
    
  
  @initialize: ->
    if Pinkman.states.empty() and window? and history? and history.replaceState?
      state = Pinkman.states.forceNew(path: window.location.pathname)
      history.replaceState({pinkey: state.pinkey}, "", state.path)
    
  @push: (path) ->
    if Pinkman.isString(path)
      path = @normalizePath(path)
      state = Pinkman.states.forceNew(path: path)
      history.pushState({ pinkey: state.pinkey }, "", path) if window? and history? and history.pushState?
  
  @normalizePath: (path) ->
    path = path.replace(window.location.origin, '')
    if path[0] == '/' then (window.location.origin + path) else (window.location.origin + '/' + path)
    
  @restore: (event) ->
    if typeof event == 'object' and event.state? and event.state.pinkey?
      state = Pinkman.states.firstOrInitialize(pinkey: event.state.pinkey)
      unless state.path?
        state.set('path',window.location.pathname)
      state.restore()
  
  restore: ->
    Pinkman.router.restore(@path)
  
Pinkman.state = PinkmanState
# 
$(document).ready ->
  if window? and history?
    window.onpopstate = (event) ->
      Pinkman.state.restore(event)
