Template.postsList.helpers
  posts: ->
    return Posts.find({}, {sort: {submitted: -1}})