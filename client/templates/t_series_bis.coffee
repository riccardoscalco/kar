Template.tSeriesBis.rendered = () ->
  
  chart = kar.g3()
      .width(900)
      .height(100)
      .period(1000 * 60 * 3)
      .showAxis(true)
      .cursor((period) ->
        Clock.find(
          { "date": { "$gte": Date.now() - period } },
          { sort: { "date": 1 } }
        )
      )
  
  d3.select(this.firstNode).call(chart)
