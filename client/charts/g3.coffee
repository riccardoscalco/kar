kar.g3 = () ->

  period = 1000 * 60
  maxDelay = 1000 * 6

  margin = { top: 20, right: 20, bottom: 20, left: 20 }
  width = 500
  height = 150
  cut = width / 20
  
  xValue = (d) -> d.date
  yValue = (d) -> d.value
  
  showAxis = false
  
  dt = 1100 # loop time
  transition = d3.select({}).transition()
      .duration(dt)
      .ease("linear")

  cursor = (period) -> undefined

  chart = (selection) ->

    X = (d) -> xScale(xValue(d))
    Y = (d) -> yScale(yValue(d))

    xScale = d3.time.scale()
        .range([0, width - margin.left - margin.right])

    yScale = d3.scale.linear()
        .domain([1,10])
        .range([height - margin.top - margin.bottom, 0])

    line = d3.svg.line()
        .interpolate("basis")
        .defined((d) -> d)
        .x(X)
        .y(Y)

    dx = (width - margin.left - margin.right) / period * dt

    svg = selection.append('svg')
        .attr('width', width)
        .attr('height', height)

    svg.append("defs").append("clipPath")
        .attr("id", "clip")
      .append("rect")
        .attr("width", width - margin.left - margin.right - 2 * cut)
        .attr("height", height)
        .attr("x", cut)

    mainG = svg.append("g")
        .attr("clip-path", "url(#clip)")
        .attr("transform", "translate(" + 
          margin.left + "," + margin.top + ")")

    group = mainG.append('g')
    
    if showAxis
      xAxis = d3.svg.axis()
          .orient("bottom")
          .tickSize(6, 0)
      axis = mainG.append("g")
          .attr("transform", "translate(0," + yScale.range()[0] + ")")
          .attr("class", "x axis")
    
    path = group.append("path")
        .attr("class","line")

    addValue = (data,datum) ->
      if (datum.date - data[data.length - 1].date) <= maxDelay
        data.concat(datum)
      else
        data.concat([undefined, datum])

    (tick = () ->

      transition = transition.each(() ->

        endingDate = Date.now()
        startingDate = endingDate - period

        xScale.domain([startingDate,endingDate])
        
        if showAxis
          axis.call(xAxis.scale(xScale))

        data = cursor(period).fetch()

        path.datum(data[1..].reduce(addValue,[data[0]]))
            .attr("d", line)
            .attr("transform", null)
          .transition()
            .attr("transform", "translate(" + (-1 * dx) + ",0)")

      ).transition().each("start", tick)
      
    )()

  # getter/setter methods

  chart.margin = (_) ->
    if not arguments.length
      margin
    else
      margin = _
      chart

  chart.width = (_) ->
    if not arguments.length
      width
    else
      width = _
      chart

  chart.height = (_) ->
    if not arguments.length
      height
    else
      height = _
      chart

  chart.x = (_) ->
    if not arguments.length
      xValue
    else
      xValue = _
      chart

  chart.y = (_) ->
    if not arguments.length
      yValue
    else
      yValue = _
      chart

  chart.maxDelay = (_) ->
    if not arguments.length
      maxDelay
    else
      maxDelay = _
      chart

  chart.period = (_) ->
    if not arguments.length
      period
    else
      period = _
      chart

  chart.cursor = (_) ->
    if not arguments.length
      cursor
    else
      cursor = _
      chart

  chart.showAxis = (_) ->
    if not arguments.length
      showAxis
    else
      showAxis = _
      chart

  chart.cut = (_) ->
    if not arguments.length
      cut
    else
      cut = _
      chart

  #return
  chart