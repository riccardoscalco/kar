kar.g5 = () -> 

  period = 1000 * 60

  margin = {top: 20, right: 20, bottom: 20, left: 20}
  
  width = 500
  height = 150 
  cut = width / 20

  showAxis = false
  
  xValue = (d) -> d.date
  yValue = (d) -> d.value
  
  dt = 1100 # loop time
  transition = d3.select({}).transition()
      .duration(dt)
      .ease("linear")

  xScale = d3.time.scale()
  yScale = d3.scale.linear()

  cursor = (period) ->

  chart = (selection) ->

    dx = (width - margin.left - margin.right) / period * dt

    xScale
        .range([0, width - margin.left - margin.right])
    
    yScale
        .domain([1,10])
        .range([1,10])

    X = (d) -> xScale(xValue(d))
    Y = (d) -> yScale(yValue(d))

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
          .attr("transform", "translate(0," + 
            ( height - margin.top - margin.bottom ) + ")")
          .attr("class", "x axis")

    (tick = () ->

      transition = transition.each(() ->

        endingDate = Date.now()
        startingDate = endingDate - period

        xScale.domain([startingDate,endingDate])
        
        if showAxis
          axis.call(xAxis.scale(xScale))

        data = cursor(period).fetch()
        elements = group.selectAll('circle').data(data)
        
        elements
          .attr('cx', X )
          .attr('cy', ( height - margin.top - margin.bottom ) / 2)
          .attr('r', Y )
        
        elements.enter().append('circle')
          .attr('cx', X )
          .attr('cy', ( height - margin.top - margin.bottom ) / 2)
          .attr('r', Y )
        
        elements.exit().remove()

        group
            .attr("transform", null)
          .transition()
            .attr("transform", "translate(" + (-1 * dx ) + ",0)")

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