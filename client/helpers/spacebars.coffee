UI.registerHelper 'pluralize', (n, thing) ->
  if (n <= 1)
    return n + ' ' + thing
  else
    return n + ' ' + thing + 's'
