###Template.tSeries.rendered = () ->
  width = 1000
  height = 35
  nElements = 50
  deltaT = 5000 # a signal arrives every deltaT/1000 seconds
  age = 1

  now = Date.now()
  x = d3.time.scale()
      .range([0,width])
  
  svg = d3.select(this.firstNode).append('svg')
    .attr('width', width)
    .attr('height', height)

  circlesG = svg.append('g')
  row = this.data.row

  draw = () ->
    now = Date.now()
    x.domain([new Date(now - 1000 * 5 * nElements),new Date(now)])
    data = Circles.findOne({'row': row}).data
    circles = circlesG.selectAll('circle').data(data)
    circles
      .attr('cx', (d) -> x(d.date))
      .attr('cy', height / 2)
      .attr('r', (d) -> d.value )
    circles.enter().append('circle')
      .attr('cx', (d) -> x(d.date))
      .attr('cy', height / 2)
      .attr('r', (d) -> d.value )
    circlesG
        .attr("transform", null)
      .transition()
        .duration(deltaT*age)
        .ease("linear")
        .attr("transform", "translate(" + 
          (x(new Date(now))-x(new Date(now + deltaT * age))) + 
          ",0)")
        .each("end", draw)
  
  update = (newDatum) ->
    circlesG
      .append('circle')
      .datum(newDatum)
        .attr('cx', (d) -> x(d.date))
        .attr('cy', height / 2)
        .attr('r', (d) -> d.value )
    circlesG.select('circle').remove()

  Circles
    .find({'row': this.data.row},{ fields: { 'latest': 1 } })
    .observeChanges({
      changed: (id, fields) ->
        update(fields.latest)
    })
  
  draw()###