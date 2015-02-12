Template.line.rendered = () ->
  
  chart = kar.line()
      .period(1000 * 60 * 15)
      .showAxis(true)
      .domain([0, 10])
      .collection(Clock)
  
  d3.select(this.firstNode).call(chart)

