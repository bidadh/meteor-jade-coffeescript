Template.errors.helpers
  errors: ->
    return Errors.find()

Template.error.rendered = ->
  error = this.data
  Meteor.setTimeout (->
    Errors.remove error._id
  ), 3000