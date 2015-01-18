Template.sidebar.helpers({
  notes: () -> Clock.find(
    { "note": { $exists: true } },
    { sort: { "date": 1 } }
  )
})
