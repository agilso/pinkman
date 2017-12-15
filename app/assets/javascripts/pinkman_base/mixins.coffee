window.Pinkman.mixin = (name,mix) ->
  if name? and typeof name == 'string' and mix? and typeof mix == 'object'
    Pinkman.mixins = new Pinkman.collection unless Pinkman.mixins?
    mixin = new Pinkman.object
    mixin.set 'mix', mix
    mixin.set 'name',name
    Pinkman.mixins.forcePush mixin

window.Pinkman.mix = (c,name) ->
  mixin = Pinkman.mixins.getBy('name',name)
  if mixin?
    for n, method of mixin.mix
      method['super'] = c.prototype[n]
      c.prototype[n] = method
    return(true)
  else
    false
    
window.Pinkman.mixit = (args...) ->
  console.log '[DEPRECATED]: Use mix instead of mixin.'
  Pinkman.mix(args...)


# --- Mixins - Usage --- #

# Pinkman.mixin 'shitty',
#   shit: (a) ->
#     "#{a} is shit"


# class window.Foo
#   Pinkman.mix this, 'shitty'

# class window.Bar extends Pinkman.object
#   @mix 'shitty'

# a = new Foo
# a.shit(abc) -> 'abc is shit'

# a = new Bar
# a.shit(abc) -> 'abc is shit'