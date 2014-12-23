kar.horizon = () ->

  period = 1000 * 60

  margin = { top: 20, right: 20, bottom: 20, left: 20 }
  width = 900
  height = 100
  cut = width / 20
  
  xValue = (d) -> d.date
  yValue = (d) -> d.value
  
  showAxis = false
  
  dt = 1000 # loop time
  transition = d3.select({}).transition()
      .duration(dt)
      .ease("linear")

  cursor = (period) -> undefined

  bands = 3
  mode = "offset" # or mirror
  interpolate = "linear" # or basis, monotone, step-before, etc.

  d3_horizonArea = d3.svg.area()
  d3_horizonId = 0

  # function d3_horizonX(d) {
  #   return d[0];
  # }

  # function d3_horizonY(d) {
  #   return d[1];
  # }

  color = d3.scale.linear()
      .domain [-1, 0, 0, 1]
      .range ["#08519c", "#bdd7e7", "#bae4b3", "#006d2c"]

  chart = (selection) ->

    # x = (d) -> xScale(xValue(d))
    # y = (d) -> yScale(yValue(d))
    x = (d) -> d[0]
    y = (d) -> d[1]

    xScale = d3.time.scale()
        .range([0, width - margin.left - margin.right])

    yScale = d3.scale.linear()
        .domain([1,10])
        .range([height - margin.top - margin.bottom, 0])

    d3_horizonTransform = (bands, height, mode) ->
      if mode == "offset"
        (d) -> "translate(0," + (d + (d < 0) - bands) * height + ")"
      else
        (d) ->
          (if d < 0 then "scale(1,-1)" else "") +
          "translate(0," + (d - bands) * h + ")"

    #For each small multiple…
    horizon = (g) ->
      g.each((d, i) ->
        g = d3.select(this)
        n = 2 * bands + 1
        xMin = Infinity
        xMax = -Infinity
        yMax = -Infinity
        x0 # old x-scale
        y0 # old y-scale
        id # unique id for paths

        #Compute x- and y-values along with extents.
        data = d.map (d, i) ->
          xv = x.call(this, d, i)
          yv = y.call(this, d, i)
          if xv < xMin then xMin = xv
          if xv > xMax then xMax = xv
          if -yv > yMax then yMax = -yv
          if yv > yMax then yMax = yv
          [xv, yv]

        #Compute the new x- and y-scales, and transform.
        x1 = d3.scale.linear().domain([xMin, xMax]).range([0, width])
        y1 = d3.scale.linear().domain([0, yMax]).range([0, height * bands])
        t1 = d3_horizonTransform(bands, height, mode)

        #Retrieve the old scales, if this is an update.
        if this.__chart__
          x0 = this.__chart__.x
          y0 = this.__chart__.y
          t0 = this.__chart__.t
          id = this.__chart__.id
        else
          x0 = x1.copy()
          y0 = y1.copy()
          t0 = t1
          id = ++d3_horizonId

        #We'll use a defs to store the area path and the clip path.
        defs = g.selectAll("defs")
            .data([null])

        #The clip path is a simple rect.
        defs.enter().append("defs").append("clipPath")
            .attr("id", "d3_horizon_clip" + id)
          .append("rect")
            .attr("width", width)
            .attr("height", height)

        # We'll use a container to clip all horizon layers at once.
        g.selectAll("g")
            .data([null])
          .enter().append("g")
            .attr("clip-path", "url(#d3_horizon_clip" + id + ")");

        # Instantiate each copy of the path with different transforms.
        path = g.select("g").selectAll("path")
            .data(d3.range(-1, -bands - 1, -1).concat(d3.range(1, bands + 1)), Number)

        d0 = d3_horizonArea
            .interpolate(interpolate)
            .x( (d) -> x0(d[0]) )
            .y0(height * bands)
            .y1((d) -> height * bands - y0(d[1]))
            (data)

        d1 = d3_horizonArea
            .x((d) -> x1(d[0])) 
            .y1((d) -> height * bands - y1(d[1]))
            (data)

        path.enter().append("path")
            .style("fill", color)
            .attr("transform", t0)
            .attr("d", d0)

      )

    dx = (width - margin.left - margin.right) / period * dt

    svg = selection.append('svg')
        .attr('width', width)
        .attr('height', height)

    svg.append("defs").append("clipPath")
        .attr("id", "clip")
      .append("rect")
        .attr("width", width - margin.left - margin.right - 1 * cut)
        .attr("height", height)
        .attr("x", cut/2)

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
        

    (tick = () ->

      transition = transition.each(() ->

        endingDate = Date.now()
        startingDate = endingDate - period

        xScale.domain([startingDate,endingDate])
        
        if showAxis
          axis.call(xAxis.scale(xScale))

        data = cursor(period).fetch()
        data = data.map( (v, i) -> [ v.date, v.value ] )

        group.select('g').remove()
        path = group.append("g").attr('class','.horizon')
        path.data([data]).call(horizon)
        path
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
      width = +_
      chart

  chart.height = (_) ->
    if not arguments.length
      height
    else
      height = +_
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

  chart.period = (_) ->
    if not arguments.length
      period
    else
      period = +_
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
      cut = +_
      chart

  chart.bands = (_) ->
    if not arguments.length
      bands
    else
      bands = +_
      color.domain [-bands, 0, 0, bands]
      chart

  chart.mode = (_) ->
    if not arguments.length
      mode
    else
      mode = _ + ""
      chart

  chart.colors = (_) ->
    if not arguments.length
      color.range()
    else
      color.range _
      chart

  chart.interpolate = (_) ->
    if not arguments.length
      interpolate
    else
      interpolate = _ + "";
      chart

  #return
  chart