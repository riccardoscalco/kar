Template.syncLine.rendered = () ->
  
  chart = kar.syncLine()
      .width(900)
      .height(100)
      .period(1000 * 60 * 3)
      .showAxis(true)
      .cursor((period) ->
        Events.find(
          { "date": { "$gte": Date.now() - period } },
          { sort: { "date": 1 } }
        )
      )
  
  d3.select(this.firstNode).call(chart)
