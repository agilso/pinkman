class window.People extends PinkmanCollection
  config:
    api: "api/people" # you should confirm this
    memberClass: ->
      return (new Person)
