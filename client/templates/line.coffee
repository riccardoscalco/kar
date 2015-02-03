Template.line.rendered = () ->
  
  chart = kar.line()
      .period(1000 * 60 * 15)
      .showAxis(true)
      .domain([0, 15])
      .collection(Clock)
  
  d3.select(this.firstNode).call(chart)


  # Tracker.autorun(() ->
  #   data = Clock.find(
  #         { "date": { "$gte": Date.now() - 3000 * 60 } },
  #         { sort: { "date": 1 } }).fetch().map((o) -> {"date": new Date(o.date), "value": o.value})

  #   if data.length > 0
  #     MG.data_graphic({
  #       title: "Downloads",
  #       description: "This graphic shows a time-series of downloads.",
  #       data: data
  #       # data: [{'date':new Date('2014-11-01'),'value':12},
  #       #        {'date':new Date('2014-11-02'),'value':18}],
  #       width: 600,
  #       height: 100,
  #       target: '#viz',
  #       x_accessor: 'date',
  #       y_accessor: 'value',
  #     })
  # )

