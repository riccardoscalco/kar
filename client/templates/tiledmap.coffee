root = this ? exports

Template.tiledmap.rendered = ->

  # resize the layout
  resize = () ->
    newHeight = $(root).height()
    $("#tiledmap").css("height", newHeight)
  # resize on load
  resize()
  # resize on resize of root
  $(root).resize => resize()
  
  map = L.map('tiledmap', {
    doubleClickZoom: false
    zoomControl: false
    # closePopupOnClick:false
    scrollWheelZoom: true
    touchZoom: true
    dragging: true
  }).setView([45.47, 9.11], 11);

  #L.tileLayer.provider('OpenStreetMap.BlackAndWhite').addTo(map);
  L.tileLayer.provider('Stamen.TonerLite').addTo(map);

  Icons = L.Icon.extend
    options:
        shadowUrl: '',
        iconSize:     [30, 30 * Math.sqrt(3) / 2],
        #shadowSize:   [0, 0],
        iconAnchor:   [15, 25 * Math.sqrt(3) / 2],
        #shadowAnchor: [0, 0],
        #popupAnchor:  [0, 0]

  imagePath = "packages/meteor-leaflet-master/images/"
  selectionIcon = new Icons { iconUrl: imagePath + "marker.svg" }

  getIcon = (o) ->
    switch o.category
      when "category_1" then new Icons { iconUrl : imagePath + "marker1.svg"}
      when "category_2" then new Icons { iconUrl : imagePath + "marker2.svg"}
      when "category_3" then new Icons { iconUrl : imagePath + "marker3.svg"}
  
  marker = undefined
  map.on("click", (event) ->
    if marker then map.removeLayer(marker)
    marker = L.marker(event.latlng, {icon: selectionIcon}).addTo(map)
    Session.set("date", Date.now())
    Session.set("coordinates", {
      "lat": event.latlng.lat
      "lng": event.latlng.lng
    })
    $("#plus").css('-webkit-animation','pulse 0.3s')
    window.setTimeout(
      () -> $("#plus").css('-webkit-animation','none')
    ,400)
  )

  period = 1000 * 60 * 10
  query = Notes.find({ 
    "date": { "$gte": Date.now() - period },
    "coordinates": { $ne: undefined }
  })
  query.observe({
    added: (document) ->
      L.marker(document.coordinates, {icon: getIcon(document)}).addTo(map)
  })