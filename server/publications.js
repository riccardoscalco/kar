Meteor.publish('events', function(timeWindow) {
  var endingDate = Date.now();
  var startingDate = endingDate - timeWindow;
  return Events.find({"date": {"$gte": startingDate}});
});

Meteor.publish('clock', function(timeWindow) {
  var endingDate = Date.now();
  var startingDate = endingDate - timeWindow;
  return Clock.find({"date": {"$gte": startingDate}});
});