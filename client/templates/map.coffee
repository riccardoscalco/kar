Template.map.rendered = ->

    map = L.map('modalTiledMap', {
      doubleClickZoom: false
      zoomControl: false
      # closePopupOnClick:false
      scrollWheelZoom: true
      touchZoom: true
      dragging: true
      trackResize: false # do not automatically handles browser window resize
    }).setView([45.47, 9.11], 11);

    L.tileLayer.provider('OpenStreetMap.BlackAndWhite').addTo(map);

    Icons = L.Icon.extend
      options:
          shadowUrl: '',
          iconSize:     [30, 30 * Math.sqrt(3) / 2],
          #shadowSize:   [0, 0],
          iconAnchor:   [15, 25 * Math.sqrt(3) / 2],
          #shadowAnchor: [0, 0],
          #popupAnchor:  [0, 0]

    imagePath = "packages/meteor-leaflet-master/images/"
    mark = new Icons { iconUrl: imagePath + "marker.svg" }
    
    marker = undefined
    map.on("click", (event) ->
      if marker then map.removeLayer(marker)
      marker = L.marker(event.latlng, {icon: mark}).addTo(map)
      Session.set("coordinates", {
        "lat": event.latlng.lat
        "lng": event.latlng.lng
      })
    )

    $("#modalTiledMap").slideToggle(500);
    $(".toggle-map").click(() -> 
        $("#modalTiledMap").slideToggle(500)
      )
