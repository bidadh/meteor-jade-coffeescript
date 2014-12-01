Template.postsList.helpers
  posts: ->
    return Posts.find({category: 'JavaScript'})