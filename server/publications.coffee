Meteor.publish('events', (timeWindow) ->
  endingDate = Date.now()
  startingDate = endingDate - timeWindow
  Events.find({"date": {"$gte": startingDate}})
)

Meteor.publish('clock', (timeWindow) ->
  endingDate = Date.now()
  startingDate = endingDate - timeWindow
  Clock.find({"date": {"$gte": startingDate}})
)