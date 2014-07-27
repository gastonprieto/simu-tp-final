var lineReader = require('line-reader');

if (process.argv.length == 2) {
  console.log('Usage: node calculate-ia.js <input_log_file>');
  exit();
}

var path = process.argv[2];
var path_out = 'ia-' + path;

var last_value = -1;
lineReader.eachLine(path, function(line, last) {
  var value = parseInt(line);
  
  if (last_value !== -1) {
    console.log(value - last_value);
  }

  last_value = value;
    
});
