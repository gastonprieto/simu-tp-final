var page = require('webpage').create();
var system = require('system');
var fs = require('fs');


if (system.args.length == 1) {
  console.log('Usage: loadspeed.js <some URL>');
  phantom.exit();
}

var t = Date.now();
var address = system.args[1];
var path = system.args[2];

fs.write('tc-' + path, t.toString() + '\n', 'a');

page.open(address, function(status) {
  if (status !== 'success') {
    console.log('Fail to load the address');
  } else {
    t = Date.now() - t;
    fs.write('ta-' + path,  t.toString() + '\n', 'a');
  }
  phantom.exit();
});
