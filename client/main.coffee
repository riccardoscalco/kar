# Get data no older than timeWindow
timeWindow = 1000 * 60 * 15

# Subscriptions
Meteor.subscribe('notes',timeWindow)
#Meteor.subscribe('events',timeWindow)
Meteor.subscribe('clock',timeWindow)