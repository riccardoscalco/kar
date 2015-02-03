kar.line = () ->

  # ---- Default Values ------------------------------------------------

  period = 1000 * 60
  lag = 1000 * 6
  margin = { top: 20, right: 0, bottom: 20, left: 0 }
  width = 900
  height = 100
  cut = width / 20
  showAxis = false
  interpolate = "step-before"
  domain = [1, 10]
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

    # svg.append("defs").append("clipPath")
    #     .attr("id", "clip-line")
    #   .append("rect")
    #     .attr("width", width - margin.left - margin.right - 2 * cut)
    #     .attr("height", height)
    #     .attr("x", cut)

    g = svg.append("g")
        #.attr("clip-path", "url(#clip-line)")
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
          .data(notesData)
      marker.enter()
          .append("line")
          .attr("y2", yScale.range()[0])
          .attr("x1", X)
          .attr("x2", X)
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

    mouseclick = () ->
      d = nearestDatum(xScale.invert(d3.mouse(this)[0]))
      # alreadyMarked = Notes.find(
      #     { 
      #       "date": d.date, 
      #       "note": { $exists: true } 
      #     }
      # ).fetch()[0]
      # if not alreadyMarked
      #   Notes.insert({
      #     "date" : d.date
      #     "note": "descr"
      #   })
      Session.set('date', d.date);
      kar.toggleModal(d3.event)

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
        .attr("x", 9)
        .attr("dy", "1em")

    svg.append("rect")
        .attr("clip-path", "url(#clip-line)")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")")
        .attr("class", "overlay")
        .attr("width", width - margin.left - margin.right)
        .attr("height", height - margin.top - margin.bottom)
        .on("mouseover", () -> focus.style("display", null))
        .on("mouseout", () -> focus.style("display", "none"))
        .on("mousemove", mousemove)
        .on("click", mouseclick)

    
    Tracker.autorun(update)

  # ---- Getter/Setter Methods -----------------------------------------

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
      domain = _
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

  chart.cut = (_) ->
    if not arguments.length
      cut
    else
      cut = _
      chart

  # --------------------------------------------------------------------
  chart