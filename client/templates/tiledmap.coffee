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
  
  L.Icon.Default.imagePath = 'packages/mrt_leaflet/images'

  
  map = L.map('tiledmap', {
    doubleClickZoom: true
    zoomControl: false
    # closePopupOnClick:false
  }).setView([45.47, 9.11], 11);

  L.tileLayer.provider('OpenStreetMap.BlackAndWhite').addTo(map);

  Icons = L.Icon.extend
    options:
        shadowUrl: '',
        iconSize:     [36, 51],
        shadowSize:   [0, 0],
        iconAnchor:   [18, 30],
        shadowAnchor: [0, 0],
        popupAnchor:  [0, -20]

  myIcon = L.icon({
    iconUrl: 'packages/mrt_leaflet/images/marker-icon.png',
    iconSize:     [38, 55], # size of the icon
    #shadowSize:   [50, 64], # size of the shadow
    iconAnchor:   [19, 55], # point of the icon which will correspond to marker's location
    #shadowAnchor: [4, 62],  # the same for the shadow
    #popupAnchor:  [-3, -76] # point from which the popup should open relative to the iconAnchor
  })


  selectionIcon = new Icons {iconUrl: 'selection.svg'}

  map.on('dblclick', (event) ->
    console.log event.latlng
    L.marker(event.latlng, {icon: myIcon}).addTo(map)
    # L.marker(event.latlng).addTo(map)
    # Markers.insert({latlng: event.latlng});
  )



  # myIcon0 = new myIcons {iconUrl: 'packages/leaflet/images/icoon.svg'}
  # # first update file package.js
  # choice1 = new myIcons {iconUrl: 'packages/leaflet/images/choice1.svg'}
  # choice2 = new myIcons {iconUrl: 'packages/leaflet/images/choice2.svg'}
  # choice3 = new myIcons {iconUrl: 'packages/leaflet/images/choice3.svg'}

  # tmpIcon = new myIcons {iconUrl: 'packages/leaflet/images/tmp.svg'}
  # #myIcon4 = new myIcons {iconUrl: 'packages/leaflet/images/icoon4.svg'}
  # #myIconsList = [myIcon1, myIcon2, myIcon3, myIcon4]

  # ###
  # root.circle = L.circle [51.508, -0.11], 1000,
  #   "id": "ciao"
  #   color: 'red'
  #   fillColor: '#f03'
  #   fillOpacity: 0.5
  # root.circle.addTo(map)
  # ###


  # # click on the map and will insert the latlng into the markers collection 
  # clickCount = 0
  # root.map.on 'click', (e) ->
  #   console.log $(".leaflet-popup")[0]
  #   if not Session.get("done")?
  #     clickCount += 1
  #     if (clickCount <= 1)
  #       Meteor.setTimeout () ->
  #         if clickCount <= 1 and not Session.get("clicked")?
  #           Session.set("clicked","true")
  #           $("#home").toggleClass("fa-map-marker fa-undo")
  #           Session.set("latlng",e.latlng)
  #           TmpMark.insert {latlng: e.latlng}
  #           #id = Markers.insert {latlng: e.latlng}
  #           #Session.set "newPost", id
  #           $("#title").collapse('hide')
  #           if $("#done").hasClass('in')
  #             $("#done").collapse("toggle")
  #           $("#content-choose").collapse('show')
  #         clickCount = 0
  #       , 500




  # # watch the markers collection
  # tmpQuery = TmpMark.find({})
  # tmpQuery.observe
  #   added: (mark) ->
  #     #ii = myIconsList[Math.floor Math.random() * (4)]
  #     root.tmpMarker = L.marker(mark.latlng, {icon: tmpIcon, opacity:1})
  #     .addTo(root.map)


  # # watch the markers collection
  # query = Markers.find({})
  # query.observe
  #   added: (mark) ->
  #     #ii = myIconsList[Math.floor Math.random() * (4)]
  #     root.newMarker = L.marker(mark.latlng, {icon: ( -> 
  #       switch mark.choice
  #         when "#choice-1" then choice1
  #         when "#choice-2" then choice2
  #         when "#choice-3" then choice3
  #       )()
  #       ,
  #       opacity:1})
  #     .addTo(root.map)
  #     root.newMarker.bindPopup("Spazio riservato alla PA, utile per fornire indicazioni relative all'intervento",{"closeOnClick":false, "closeButton":true})