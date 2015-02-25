Template.tiledmap.rendered = ->
  
  map = kar.tiledMap()
      .period(1000 * 60 * 15)

  map('mytiledmap')
