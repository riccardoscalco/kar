Template.noteItem.helpers({
  formattedDate: () ->
    d = new Date(this.date) + ""
    #d[4..9] + ", " + d[16..20]
    d[4..6] + ". " + d[7..9]
  categoryClass: () ->
    switch this.category
      when "category_1" then "cat1_color"
      when "category_2" then "cat2_color"
      when "category_3" then "cat3_color"
})
