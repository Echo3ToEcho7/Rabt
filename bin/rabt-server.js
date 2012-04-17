var argv = require('optimist')
	.alias('p', 'port')
	.default('p', 3000)
	.argv;

var express = require('express');

exports.run = function run() {
	console.log("Server running on port " + argv.p);
}