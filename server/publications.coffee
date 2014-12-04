Meteor.publish 'posts', (author)->
  return Posts.find({flagged:false})