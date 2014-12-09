Package.describe({
  name: 'bidadh:errors',
  summary: 'A pattern to display application errors to the user',
  version: '1.0.0',
  git: ' /* Fill me in! */ '
});

Package.onUse(function(api) {
  api.versionsFrom('1.0');

  api.use(['minimongo', 'mongo-livedata', 'templating'], 'client');

  api.addFiles(['errors.js', 'errors_list.html', 'errors_list.js'], 'client');

  if (api.export)
    api.export('Errors');

});

Package.onTest(function(api) {
  api.use('tinytest');
  api.use('bidadh:errors');
  api.addFiles('bidadh:errors-tests.js');
});
