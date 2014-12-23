kar.g4 = () ->

  bands = 1 # between 1 and 5, typically
  mode = "offset" # or mirror
  interpolate = "linear" # or basis, monotone, step-before, etc.
  x = d3_horizonX
  y = d3_horizonY
  w = 960
  h = 40

  color = d3.scale.linear()
      .domain([-1, 0, 0, 1])
      .range(["#08519c", "#bdd7e7", "#bae4b3", "#006d2c"])

  # For each small multiple…
  horizon = (g) ->
    g.each (d, i) ->
      g = d3.select(this)
      n = 2 * bands + 1
      xMin = Infinity
      xMax = -Infinity
      yMax = -Infinity
      x0 # old x-scale
      y0 # old y-scale
      id # unique id for paths

      # Compute x- and y-values along with extents.
      data = d.map (d, i) ->
        xv = x.call(this, d, i)
        yv = y.call(this, d, i)
        if xv < xMin then xMin = xv
        if xv > xMax then xMax = xv
        if -yv > yMax then yMax = -yv
        if yv > yMax then yMax = yv
        [xv, yv]
      

      # Compute the new x- and y-scales, and transform.
      x1 = d3.scale.linear().domain([xMin, xMax]).range([0, w])
      y1 = d3.scale.linear().domain([0, yMax]).range([0, h * bands])
      t1 = d3_horizonTransform(bands, h, mode)

      # Retrieve the old scales, if this is an update.
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

      # We'll use a defs to store the area path and the clip path.
      defs = g.selectAll("defs")
          .data([null])

      # The clip path is a simple rect.
      defs.enter().append("defs").append("clipPath")
          .attr("id", "d3_horizon_clip" + id)
        .append("rect")
          .attr("width", w)
          .attr("height", h)


      # We'll use a container to clip all horizon layers at once.
      g.selectAll("g")
          .data([null])
        .enter().append("g")
          .attr("clip-path", "url(#d3_horizon_clip" + id + ")")

      # Instantiate each copy of the path with different transforms.
      path = g.select("g").selectAll("path")
          .data(d3.range(-1, -bands - 1, -1).concat(d3.range(1, bands + 1)), Number)

      d0 = d3_horizonArea
          .interpolate(interpolate)
          .x((d) -> x0(d[0]))
          .y0(h * bands)
          .y1((d) -> h * bands - y0(d[1]))
          (data)

      d1 = d3_horizonArea
          .x((d) -> x1(d[0]))
          .y1((d) -> h * bands - y1(d[1]))
          (data)

      path.enter().append("path")
          .style("fill", color)
          .attr("transform", t0)
          .attr("d", d0)

    

  horizon.bands = (x) ->
    if not arguments.length
      bands
    else
      bands = +x
      color.domain([-bands, 0, 0, bands])
      horizon

  horizon.mode = (x) ->
    if not arguments.length
      mode
    else
      mode = x + ""
      horizon

  horizon.colors = (x) ->
    if not arguments.length
      color.range()
    else
      color.range(x)
      horizon

  horizon.interpolate = (x) ->
    if not arguments.length
      interpolate
    else
      interpolate = x + ""
      horizon

  horizon.x = (z) ->
    if not arguments.length
      x
    else
      x = z
      horizon

  horizon.y = (z) ->
    if not arguments.length
      y
    else
      y = z
      horizon

  horizon.width = (x) ->
    if not arguments.length
      w
    else
      w = +x
      horizon

  horizon.height = (x) ->
    if not arguments.length
      h
    else
      h = +x
      horizon

  horizon

d3_horizonArea = d3.svg.area()
d3_horizonId = 0

d3_horizonX = (d) -> d[0]

d3_horizonY = (d) -> d[1]

d3_horizonTransform = (bands, h, mode) ->
  if mode == "offset"
    (d) -> "translate(0," + (d + (d < 0) - bands) * h + ")"
  else
    (d) -> (if d < 0 then "scale(1,-1)" else "") +
    "translate(0," + (d - bands) * h + ")"
