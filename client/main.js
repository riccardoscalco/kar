var timeWindow = 1000 * 60 * 3;
Meteor.subscribe('events',timeWindow);
Meteor.subscribe('clock',timeWindow);