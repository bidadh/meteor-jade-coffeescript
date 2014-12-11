Router.configure
  layoutTemplate: 'layout'
  loadingTemplate: 'loading'
  notFoundTemplate: 'notFound'
  waitOn: ->
    [
      Meteor.subscribe('notifications')
    ]


Router.route '/posts/:_id',
  name: 'postPage'
  data: ->
    return Posts.findOne this.params._id
  waitOn: ->
    return Meteor.subscribe('comments', this.params._id)

Router.route '/posts/:_id/edit',
  name: 'postEdit'
  data: ->
    return Posts.findOne this.params._id

Router.route '/submit',
  name: 'postSubmit'

Router.route '/:postsLimit?',
  name: 'postsList'
  waitOn: ->
    limit = parseInt(this.params.postsLimit) or 5
    Meteor.subscribe('posts', {sort: {submitted: -1}, limit: limit})
  data: ->
    limit = parseInt(this.params.postsLimit) or 5
    posts: Posts.find({}, {sort: {submitted: -1}, limit: limit})

requireLogin = ->
  if(! Meteor.user())
    if(Meteor.loggingIn())
      this.render this.loadingTemplate
    else
      this.render 'accessDenied'
  else
    this.next()

Router.onBeforeAction 'dataNotFound',
  only: 'postPage'

Router.onBeforeAction requireLogin,
  only: 'postSubmit'

