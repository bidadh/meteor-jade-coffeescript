Template.postItem.helpers
  domain: ->
    a = document.createElement 'a'
    a.href = this.url
    a.hostname
  ownPost: ->
    this.userId == Meteor.userId()
  commentsCount: ->
    Comments.find({postId: this._id}).count()

Template.postItem.events
  'click .upvote': (e) ->
    e.preventDefault()
    Meteor.call 'upvote', this._id