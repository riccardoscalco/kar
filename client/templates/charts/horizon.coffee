Template.horizon.rendered = () ->
  
  chart = kar.horizon()
      .period(1000 * 60 * 15)
      .showAxis(true)
      .collection(Clock)
      .y((d) -> d.value * d.value * d.value)
  
  d3.select(this.firstNode).call(chart)