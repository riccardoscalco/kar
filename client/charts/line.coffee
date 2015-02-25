kar.line = () ->

  # ---- Default Values ------------------------------------------------

  period = 1000 * 60
  lag = 1000 * 6
  margin = { top: 20, right: 0, bottom: 20, left: 0 }
  width = 900
  height = 100
  showAxis = false
  interpolate = "cardinal"
  domain = undefined
  collection = undefined
  xValue = (d) -> d.date
  yValue = (d) -> d.value

  # --------------------------------------------------------------------

  chart = (selection) ->

    X = (d) -> xScale(xValue(d))
    Y = (d) -> yScale(yValue(d))

    xScale = d3.time.scale()
        .range([0, width - margin.left - margin.right])

    yScale = d3.scale.linear()
        .domain(domain)
        .range([height - margin.top - margin.bottom, 0])

    line = d3.svg.line()
        .interpolate(interpolate)
        .defined((d) -> d)
        .x(X)
        .y(Y)

    svg = selection.append('svg')
        .attr('width', width)
        .attr('height', height)
        .attr("viewBox", "0 0 " + width + " " + height)
        .attr("preserveAspectRatio", "xMidYMidmeet")

    g = svg.append("g")
        .attr("transform", "translate(" + 
          margin.left + "," + margin.top + ")")
        
    plot = g.append('g')
    notes = g.append('g').attr("class", "notes")
    
    if showAxis
      xAxis = d3.svg.axis()
          .orient("bottom")
          .tickSize(6, 0)
      axis = g.append("g")
          .attr("transform", "translate(0," + yScale.range()[0] + ")")
          .attr("class", "x axis")
    
    path = plot.append("path")
        .attr("class","line")
    if interpolate[..3] is "step"
        path.style("shape-rendering", "crispEdges")

    addValue = (data, datum) ->
      if (datum.date - data[data.length - 1].date) <= lag
        data.concat(datum)
      else
        data.concat([undefined, datum])
    
    data = []

    update = () ->
      data = collection.find(
          { "date": { "$gte": Date.now() - period } },
          { sort: { "date": 1 } }).fetch()
      notesData = Notes.find(
          { "date": { "$gte": Date.now() - period } },
          { sort: { "date": 1 } }).fetch()

      endingDate = Date.now()
      startingDate = endingDate - period
      xScale.domain([startingDate,endingDate])
      if showAxis
        axis.call(xAxis.scale(xScale))
      path.datum(data[1..].reduce(addValue,[data[0]]))
          .attr("d", line)

      marker = notes.selectAll("line")
          .data(notesData, (d) -> d._id)
      marker.enter()
          .append("line")
          .attr("y2", yScale.range()[0])
          .attr("x1", X)
          .attr("x2", X)
          .attr("class", (d) -> d.category)
      marker.attr("x1", X).attr("x2", X)
      marker.exit().remove()

    bisectDate = d3.bisector((d) -> d.date).left
    nearestDatum = (x) -> 
      i = bisectDate(data, x, 1)
      d0 = data[i - 1]
      d1 = data[i]
      if x - d0.date > d1.date - x then d = d1 else d = d0

    mousemove = () ->
      d = nearestDatum(xScale.invert(d3.mouse(this)[0]))
      focus.attr("transform", "translate(" + X(d) + ",0)")
      focus.select("text").text(yValue(d))

    focus = g.append("g")
      .attr("class", "focus")
      .style("display", "none")

    focus.append("line")
        .attr("y2", yScale.range()[0])
        .style("stroke-dasharray","2, 2")
        .on("mouseover", () ->
          d3.select(this).style("stroke-width", "4px")
        )

    focus.append("text")
        .attr("x", -9)
        .attr("dy", "1em")
        .style("text-anchor", "end")

    pressTimer = undefined
    mobile = kar.mobilecheck
    eventtype = if mobile then 'touchstart' else 'click'

    svg.append("rect")
        .attr("clip-path", "url(#clip-line)")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")")
        .attr("class", "overlay")
        .attr("width", width - margin.left - margin.right)
        .attr("height", height - margin.top - margin.bottom)
        .on("mouseover", () -> focus.style("display", null))
        .on("mouseout", () -> focus.style("display", "none"))
        .on("mousemove", mousemove)
        .on(eventtype, () ->
          position = d3.mouse(this)[0]
          d = nearestDatum(xScale.invert(position))
          Session.set('date', d.date)
          Session.set("coordinates", undefined)
          if not mobile
            kar.toggleModal(d3.event)
          else
            kar.pulse()
        )
    
    Tracker.autorun(update)

  # ---- Getter/Setter Methods -----------------------------------------

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

  chart.lag = (_) ->
    if not arguments.length
      lag
    else
      lag = _
      chart

  chart.interpolate = (_) ->
    if not arguments.length
      interpolate
    else
      interpolate = _
      chart

  chart.domain = (_) ->
    if not arguments.length
      domain
    else
      domain = [ _[0], _[1] * 1.5 ]
      chart

  chart.period = (_) ->
    if not arguments.length
      period
    else
      period = _
      chart

  chart.collection = (_) ->
    if not arguments.length
      collection
    else
      collection = _
      chart

  chart.showAxis = (_) ->
    if not arguments.length
      showAxis
    else
      showAxis = _
      chart

  # --------------------------------------------------------------------
  
  chart