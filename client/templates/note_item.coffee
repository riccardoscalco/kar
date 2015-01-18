Template.noteItem.helpers({
  formattedDate: () ->
    d = new Date(this.date) + ""
    #d[4..9] + ", " + d[16..20]
    d[4..9]
})