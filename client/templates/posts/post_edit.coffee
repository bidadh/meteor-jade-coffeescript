Template.postEdit.events
  'submit form': (e) ->
    e.preventDefault()

    currentPostId = this._id

    postProperties =
      url: $(e.target).find('[name=url]').val()
      title: $(e.target).find('[name=title]').val()

    Meteor.call 'postUpdate', postProperties, this._id, (error, result) ->
      if(result.accessDenied)
        return alert('Access Denied!')
      if(result.postExists)
        alert('This link has already been posted')
      Router.go 'postPage',
        _id: currentPostId

  'click .delete': (e) ->
    e.preventDefault()
    if(confirm('Delete this Post?'))
      currentPostId = this._id
      Meteor.call 'postRemove', currentPostId, (error, result) ->
        if(error)
          return alert error.reason
        if(result.accessDenied)
          return alert('Access Denied!')
        Router.go 'postsList'
