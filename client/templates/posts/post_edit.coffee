Template.postEdit.created = ->
  Session.set 'postSubmitErrors', {}

Template.postEdit.helpers
  errorMessage : (field) ->
    return Session.get('postSubmitErrors')[field]
  errorClass : (field) ->
    return (if !!Session.get("postSubmitErrors")[field] then "has-error" else "")

Template.postEdit.events
  'submit form': (e) ->
    e.preventDefault()

    currentPostId = this._id

    postProperties =
      url: $(e.target).find('[name=url]').val()
      title: $(e.target).find('[name=title]').val()

    errors = validatePost(postProperties);
    if(errors.title || errors.url)
      return Session.set 'postSubmitErrors', errors

    Meteor.call 'postUpdate', postProperties, this._id, (error, result) ->
      if(result.accessDenied)
        Errors.throw 'Access Denied!'
      if(result.postExists)
        Errors.throw 'This link has already been posted'
      Router.go 'postPage',
        _id: currentPostId

  'click .delete': (e) ->
    e.preventDefault()

    if(confirm('Delete this Post?'))
      currentPostId = this._id
      Meteor.call 'postRemove', currentPostId, (error, result) ->
        if(error)
          Errors.throw error.reason
        if(result.accessDenied)
          Errors.throw 'Access Denied!'
        Router.go 'home'
