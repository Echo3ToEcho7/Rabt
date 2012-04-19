var argv = require('optimist')
	.alias('p', 'port')
	.default('p', 3000)
	.alias('s', 'server')
	.default('s', 'demo01')
	.alias('u', 'username')
	.default('u', 'paul@acme.com')
	.alias('w', 'password')
	.default('w', 'Just4Rally')
	.argv;

var fs = require('fs');
var request = require('request');
var app = require('express').createServer();
var cwd = process.cwd();
var _ = require('underscore');
var mkdirp = require('mkdirp');
var path = require('path');

var objects = require(cwd + "/cache/objects");
var queries = require(cwd + "/cache/queries");

var rallyServer = "https://" + argv.s + ".rallydev.com"

var createQueryKey = function createQueryKey(req) {
	return "" + req.route.params[0] + "::"
		+ req.query.query + "::" + req.query.workspace + "::"
		+ req.query.project + "::" + (req.query.projectScopeUp === true) + "::" + (req.query.projectScopeDown === true);
};

var oidFromRef = function oidFromRef(ref) {
	var matches = /(\d*)\.js/.exec(ref);
	//console.log(matches);
	return matches[1];
};

var processRequest = function processRequest(req, res) {
	console.log("Requesting " + req.url);
	//console.log(req);
	
	var i, ii;
	var items;
	var results;
	var oid;
	var appPath;
	var options = {
		method: req.route.method,
		url: rallyServer + req.url,
		headers: {
			'Authorization': 'Basic ' + (new Buffer(argv.u + ':' + argv.w)).toString('base64')
		}
	};
	
	if (options.method === 'post') {
	}
	
	request(options, function(err, resp, body) {
		try {
			items = JSON.parse(body);
			//console.log(items.QueryResult.Results);
			results = items.QueryResult.Results;
			
			for (i = 0, ii = results.length; i < ii; i++) {
				oid = oidFromRef(results[i]._ref);
				if (objects.hasOwnProperty(oid) && objects[oid]) {
					_.extend(objects[oid], results[i]);
				} else {
					objects[oid] = results[i];
				}
				
				if (!(_.isArray(queries[createQueryKey(req)]))) {
					queries[createQueryKey(req)] = []
				}
				
				if (!_.include(queries[createQueryKey(req)], oid)) {
					queries[createQueryKey(req)].push(oid);
				}
			}
			
			//console.log("Writing Cache out to file");
			fs.writeFileSync(cwd + "/cache/objects.json", JSON.stringify(objects, null, 4), "utf8");
			fs.writeFileSync(cwd + "/cache/queries.json", JSON.stringify(queries, null, 4), "utf8");
		} catch (e) {
			appPath = cwd + '/cache' + req.route.path.replace('*', '');
			var splitPath = req.route.params[0].replace('*', '').split('/');
			for (i=0, ii = splitPath.length - 1; i < ii; i++) {
				appPath = path.join(appPath, splitPath[i]);
			}
			console.log(appPath);
			console.log(path.join(appPath, _.last(splitPath)));
			mkdirp.sync(appPath);
			fs.writeFileSync(path.join(appPath, _.last(splitPath)), body, "utf8");
			//console.log(e);
		}
		res.send(body);
	});
};

exports.run = function run() {
	app.get('/', function(req, res) {
		fs.readFile(cwd + '/app.html', 'utf8', function(err, appFile) {
			res.send(appFile);
		});
	});
	
	app.get('/apps/*', processRequest);

	app.get ('/slm/*', processRequest);
	//app.post('/slm/*', processRequest);
	//app.put ('/slm/*', processRequest);
	
	app.listen(argv.p);
	console.log("Server running on port " + argv.p);
}