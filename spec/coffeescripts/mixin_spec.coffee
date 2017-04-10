describe 'Pinkman Mixins', ->

  it 'mixin: defines a mixin', ->
    expect(Pinkman.mixin 'a', {'foo': ->  }).toBeTruthy()

  it 'mixin: inserts any mixin in Pinkman.mixins (a Pinkman Collection)', ->
    Pinkman.mixin 'b', {'otherFoo': ->}
    expect(Pinkman.mixins.getBy('name','b')).not.toBe undefined

  it 'mixin: is a object with name property and mix property', ->
    Pinkman.mixin 'c', {'anotherFoo': ->}
    expect(Pinkman.mixins.getBy('name','c').name).not.toBe undefined
    expect(Pinkman.mixins.getBy('name','c').mix).not.toBe undefined

  it 'mixit: include a mixin in a class', ->
    # defines a mixin
    Pinkman.mixin 'bar', 
      yes: ->
        return('success')
    
    # inserts a mixin in a generic class
    class Foo
      Pinkman.mixit this, 'bar'
    
    # inserts a mixin in a pinkman class
    class Bar extends PinkmanCommon
      @mixit 'bar'
    
    # instantiates
    f = new Foo
    b = new Bar

    # expectations
    expect(f.yes()).toEqual 'success'
    expect(b.yes()).toEqual 'success'
