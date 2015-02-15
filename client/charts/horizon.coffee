kar.horizon = () ->

  # ---- Default Values ------------------------------------------------

  period = 1000 * 60
  lag = 1000 * 6
  margin = { top: 20, right: 0, bottom: 20, left: 0 }
  width = 900
  height = 100
  showAxis = false
  interpolate = "basis"
  collection = undefined
  xValue = (d) -> d.date
  yValue = (d) -> d.value
  bands = 2
  mode = 'offset'
  colors = ['#95A472','#fff','#fff','#bca600']
  # colors = ['#95A472','#fff','#fff','#464655']

  # --------------------------------------------------------------------

  chart = (selection) ->

    X = (d) -> xScale(xValue(d))

    xScale = d3.time.scale()
        .range([0, width - margin.left - margin.right])

    yRange = height - margin.top - margin.bottom

    horizon = d3.horizon()
        .width(width - margin.left - margin.right)
        .height(height - margin.top * 3/2 - margin.bottom * 3/2)
        .bands(bands)
        .interpolate(interpolate)
        .mode(mode)
        .period(period)
        .colors(colors)
        .x(xValue)
        .y(yValue)

    svg = selection.append('svg')
        .attr('width', width)
        .attr('height', height)
        .attr("viewBox", "0 0 " + width + " " + height)
        .attr("preserveAspectRatio", "xMidYMidmeet")

    g = svg.append("g")
        .attr("transform", "translate(" + 
          margin.left + "," + margin.top + ")")
        
    plot = g.append('g')
        .attr("transform", "translate(0," + margin.top + ")")
    
    notes = g.append('g').attr("class", "notes")
    
    if showAxis
      xAxis = d3.svg.axis()
          .orient("bottom")
          .tickSize(6, 0)
      axis = g.append("g")
          .attr("transform", "translate(0," + yRange + ")")
          .attr("class", "x axis")

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
      if showAxis then axis.call(xAxis.scale(xScale))
      
      plot
          .data([data[1..].reduce(addValue,[data[0]])])
          .call(horizon)

      marker = notes.selectAll("line")
          .data(notesData, (d) -> d._id)
      marker.enter()
          .append("line")
          .attr("y2", yRange)
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
        .attr("y2", yRange)
        .style("stroke-dasharray","2, 2")

    focus.append("text")
        .attr("x", -9)
        .attr("dy", "1em")
        .style("text-anchor", "end")

    pressTimer = undefined
    mobile = kar.mobilecheck()
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
          if not mobile
            kar.toggleModal(d3.event)
          else
            $("#plus").css('-webkit-animation','pulse 0.3s')
            window.setTimeout(
              () -> $("#plus").css('-webkit-animation','none')
            ,400)
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

  chart.bands = (_) ->
    if not arguments.length
      bands;
    else
      bands = +_
      color.domain([-bands, 0, 0, bands])
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
      color.range(_)
      chart

  # --------------------------------------------------------------------
  chart