Package.describe({
  name: 'ricsca:kar',
  summary: 'scaffold library for reative data visuzlization',
  version: '1.0.0',
  git: ' /* Fill me in! */ '
});

Package.onUse(function(api) {
  api.versionsFrom('1.0');
  api.addFiles('ricsca:kar.js');
});

Package.onTest(function(api) {
  api.use('tinytest');
  api.use('ricsca:kar');
  api.addFiles('ricsca:kar-tests.js');
});
