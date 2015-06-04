// Generated by CoffeeScript 1.9.2
var CSON, Exe, app, bodyParser, buildqueries, compression, express, fs, loadinvite, oneDay, path, port, queryexe, store;

express = require('express');

compression = require('compression');

bodyParser = require('body-parser');

app = express();

app.use(compression());

app.use(bodyParser.urlencoded({
  extended: true
}));

app.use(bodyParser.json());

oneDay = 1000 * 60 * 60 * 24;

app.use(express["static"](__dirname, {
  maxAge: oneDay
}));

loadinvite = function(key, value) {
  return function(cb) {};
};

path = require('path');

CSON = require('cson');

store = require('odoql-store');

store = store().use('invite', function(params, cb) {
  var file, filename;
  filename = params + ".cson";
  file = path.join(__dirname, 'data', filename);
  return CSON.load(file, function(err, results) {
    if (err != null) {
      console.log(err);
      return cb(err);
    }
    return cb(null, results);
  });
});

Exe = require('odoql-exe');

buildqueries = require('odoql-exe/buildqueries');

queryexe = Exe().use(store);

app.post('/query', function(req, res, next) {
  var run;
  run = buildqueries(queryexe, req.body.q);
  return run(function(errors, results) {
    if (errors != null) {
      return next(errors);
    }
    return res.send(results);
  });
});

fs = require('fs');

app.post('/submit', function(req, res) {
  var data, filename, filepath;
  filename = req.query.code + ".cson";
  filepath = path.join(__dirname, 'data', filename);
  data = CSON.stringify(req.body);
  return fs.writeFile(filepath, data, function(err) {
    if (err != null) {
      throw err;
    }
    return res.end('ok');
  });
});

app.get('/*', function(req, res) {
  return res.sendFile(path.join(__dirname, 'index.html'));
});

port = 8085;

app.listen(port);

console.log("Wedding is listening on port " + port + "...");
