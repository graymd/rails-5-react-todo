require('babel-polyfill');

var context = require.context('.', true, /.+\_spec.js/);
context.keys().forEach(context);
module.exports = context;
