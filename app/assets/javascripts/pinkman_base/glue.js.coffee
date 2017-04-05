class window.PinkmanGlue
  @_allCount = 0
  
  @increaseCount: ->
    @_allCount++

  @count: ->
    @_allCount

  @collections = []
  @objects = []
  @all = []

  @get: (id) ->
    this.all[id]