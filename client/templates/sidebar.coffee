Template.sidebar.helpers({
  notes: () -> Notes.find( {}, { sort: { "date": -1 } } )
})
