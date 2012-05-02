var argv = require('optimist')
	.alias('r', 'port')
	.default('r', 3000)
	
	.alias('s', 'server')
	.default('s', 'rally1')
	
	.alias('u', 'username')
	//.default('u', 'dan@acme.com')
	
	.alias('p', 'password')
	//.default('p', 'AcmeUser')
	
	.alias('o', 'offline')
	.boolean('o')

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

var processSLMCache = function processSLMCache(req, res) {
	var qKey = createQueryKey(req);
	var i;
	var start = parseInt(req.query.start, 10) || 1;
	var pagesize = parseInt(req.query.pagesize, 10) || 200;
	var len;
	var ret = {
		Errors: [],
		Warnings: [],
		_rallyAPIMajor: "1",
		_rallyAPIMinor: "31"
	}
	var rItems = [];
	
	if (!_.include(_.keys(queries), qKey)) {
		//console.log(qKey);
		//console.log(_.keys(queries));
		ret.Errors.push("Query not found in the test cache");
		res.json(ret);
		return;
	}
	
	if (start > queries[qKey].length) {
		ret.Errors.push("Start is outside the test cache");
		res.json(ret);
		return;
	}
	
	len = start + pagesize;
	//console.log("First Len", len, pagesize);
	if (len > queries[qKey].length) {
		len = queries[qKey].length - start + 1;
	}
	
	//console.log("Start, Len", start, len);
	for (i = start - 1; i < len; i++) {
		//console.log("Item at ", i, queries[qKey][i]);
		rItems.push(objects[queries[qKey][i]]);
	}
	
	if (req.route.params[0].indexOf("User") !== -1) {
		ret.User = rItems[0];
	} else {
		ret.Results = rItems;
		ret.StartIndex = parseInt(""+start, 10);
		ret.PageSize = parseInt(""+pagesize, 10);
		ret.TotalResultCount = queries[qKey].length;
		
		ret = {QueryResult: ret};
	}
	//console.log(ret);
	
	res.json(ret);
};

var processAppsCache = function processAppsCache(req, res) {
	var appPath = cwd + '/cache' + req.route.path.replace('*', '');
	var splitPath = req.route.params[0].replace('*', '').split('/');
	for (i=0, ii = splitPath.length - 1; i < ii; i++) {
		appPath = path.join(appPath, splitPath[i]);
	}
	
	fs.readFile(path.join(appPath, _.last(splitPath)), function(err, data) {
		var type = "text/html";
		var page = req.route.params[0];
		
		if (page.indexOf('.js') !== -1) {
			type = "text/javascript";
		} else if (page.indexOf('.css') !== -1) {
			type = "text/css";
		} else if (page.indexOf('.gif') !== -1) {
			type = "image/gif";
		}
		
		if (err) {
			res.send(404);
		} else {
			res.send(data, { 'Content-Type': type });
		}
	});
};

var processRequestWithCache = function processRequestWithCache(req, res) {
	if (req.route.path === "/slm/*") {
		processSLMCache(req, res);
	} else {
		processAppsCache(req, res);
	}
};

var processRequestAndCache = function processRequestAndCache(req, res) {
	console.log("Requesting " + req.url);
	//console.log(req);
	
	var i, ii;
	var k;
	var items;
	var results;
	var oid;
	var appPath;
	var options = {
		method: req.route.method,
		url: rallyServer + req.url,
		headers: {
			'Authorization': 'Basic ' + (new Buffer(argv.u + ':' + argv.p)).toString('base64')
		}
	};
	
	request(options, function(err, resp, body) {
		try {
			items = JSON.parse(body);
			//console.log(items.QueryResult.Results);
			if (_.include(_.keys(items), 'QueryResult')) {
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
			} else {
				for (k in items) {
					if (items.hasOwnProperty(k)) {
						oid = oidFromRef(items[k]._ref);
						
						if (objects.hasOwnProperty(oid) && objects[oid]) {
							_.extend(objects[oid], items[k]);
						} else {
							objects[oid] = items[k];
						}

						if (!(_.isArray(queries[createQueryKey(req)]))) {
							queries[createQueryKey(req)] = []
						}

						if (!_.include(queries[createQueryKey(req)], oid)) {
							queries[createQueryKey(req)].push(oid);
						}
					}
				}
			}
			
			console.log("Writing Cache out to file");
			fs.writeFileSync(cwd + "/cache/objects.json", JSON.stringify(objects, null, 4), "utf8");
			fs.writeFileSync(cwd + "/cache/queries.json", JSON.stringify(queries, null, 4), "utf8");
		} catch (e) {
			console.error(e);
			appPath = cwd + '/cache' + req.route.path.replace('*', '');
			var splitPath = req.route.params[0].replace('*', '').split('/');
			for (i=0, ii = splitPath.length - 1; i < ii; i++) {
				appPath = path.join(appPath, splitPath[i]);
			}
			
			//console.log(appPath);
			//console.log(path.join(appPath, _.last(splitPath)));
			var enc = "utf8"
			
			if (resp.headers['content-type'].indexOf('image/') >= 0) {
				enc = 'binary';
			}
			
			console.log("Encoding", enc, resp.headers['content-type']);
			
			mkdirp.sync(appPath);
			//request(options).pipe(fs.createWriteStream(path.join(appPath, _.last(splitPath))));
			fs.writeFileSync(path.join(appPath, _.last(splitPath)), body, enc);
			//console.log(e);
		}
		
//		console.log("Resp", resp);
		res.send(body, resp.headers);
	});
};

exports.run = function run() {
	var processRequest = argv.o ? processRequestWithCache : processRequestAndCache;
	
	app.get('/', function(req, res) {
		fs.readFile(cwd + '/bin/app.html', 'utf8', function(err, appFile) {
			res.send(appFile);
		});
	});
	
	app.get('/apps/*', processRequest);

	app.get ('/slm/*', processRequest);
	//app.post('/slm/*', processRequest);
	//app.put ('/slm/*', processRequest);
	
	app.listen(argv.r);
	console.log("Server running on port " + argv.r);
}