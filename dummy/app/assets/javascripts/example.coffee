Pinkman.controller 'example', (c) ->

  c.main = ->
    console.log 'example'
    window.people = new People
    people.fetch (p) ->
      p.render 'listing'
      p.new().render 'form'

    c.bind ['name','email','age']

  c.action 'save', 'click', (person,jquery) ->
    people.new().render 'form'
    people.push(person)
    people.reRender()
    person.save()

  c.action 'edit', 'click', (person,jquery) ->
    jquery.parent().siblings().css('color','inherit')
    jquery.parent().css('color','#1E90FF')
    person.render 'form'

  c.action 'destroy', 'click', (person) ->
    person.destroy ->
      people.reRender()
