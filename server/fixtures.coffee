# getRandomInt(2, 8)
getRandomInt = (min, max) ->
  Math.floor(Math.random() * (max - min + 1)) + min

Meteor.startup () -> 
  # if the Events collection doesn't have any records in it
  if (Events.find().count() is 0)
    
    # ensureIndex on the server side
    Events._ensureIndex({ "date": -1});

    endingDate = Date.now()
    deltaTime = 1000 * 60 # 1 minute
    startingDate = endingDate - deltaTime
    
    n = 100 # initial number of elements
    for i in [1..n]
      Events.insert {
        'date' : getRandomInt(startingDate, endingDate)
        'value' : getRandomInt(1,10)
      }

dt = 1000 # a signal arrives every dt/1000 seconds
Meteor.setInterval(() ->
  Clock.insert {
      'date' : Date.now()
      'value' : getRandomInt(1,10)
    }
  if (getRandomInt(1,10) >= 8)
    Events.insert {
      'date' : Date.now()
      'value' : getRandomInt(1,10)
    }
,dt)