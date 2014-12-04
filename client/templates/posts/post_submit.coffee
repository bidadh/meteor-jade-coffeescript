Template.postSubmit.events
  'submit form': (e) ->
    e.preventDefault()
    post =
      url: $(e.target).find('[name=url]').val()
      title: $(e.target).find('[name=title]').val()
      category: 'JavaScript'
      author: 'bob-smith'
      flagged: false

    post._id = Posts.insert post
    Router.go 'postPage', post