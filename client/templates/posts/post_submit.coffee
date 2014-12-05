Template.postSubmit.events
  'submit form': (e) ->
    e.preventDefault()
    post =
      url: $(e.target).find('[name=url]').val()
      title: $(e.target).find('[name=title]').val()
      category: 'JavaScript'

    Meteor.call 'postInsert', post, (error, result) ->
      if(error)
        return alert(error.reason)
      if(result.postExists)
        alert('This link has already been posted')
    Router.go 'postsList'
#    Router.go 'postPage',
#      _id: result._id
