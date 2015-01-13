Template.tSeries.rendered = () ->
  
  chart = kar.g5()
      .width(900)
      .height(100)
      .period(1000 * 60 * 3)
      .showAxis(true)
      .cursor((period) ->
        Clock.find(
          {"date": {"$gte": Date.now() - 2000 - period}},
          {sort:{"date": 1 }}
        )
      )
  
  d3.select(this.firstNode).call(chart)
