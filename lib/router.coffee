Router.configure
  layoutTemplate: 'layout'
  loadingTemplate: 'loading'
  waitOn: ->
    Meteor.subscribe 'posts', 'bob-smith'

Router.route '/',
  name: 'postsList'
