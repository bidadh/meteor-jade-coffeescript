Template.postEdit.events
  'submit form': (e) ->
    e.preventDefault()

    currentPosyId = this._id

    postProperties =
      url: $(e.target).find('[name=url]').val()
      title: $(e.target).find('[name=title]').val()

    Posts.update currentPosyId,
      $set: postProperties,
      (error) ->
        if(error)
          return alert(error.reason)
        else
          Router.go 'postPage',
            _id: currentPosyId

  'click .delete': (e) ->
    e.preventDefault()
    if(confirm('Delete this Post?'))
      currentPostId = this._id
      Posts.remove currentPostId
      Router.go 'postsList'
