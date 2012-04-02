fs = require 'fs'
path = require 'path'
underscore = require 'underscore'
reporter = require 'jslint/lib/reporter'

compilers = {}

compilers.JavascriptCompiler = exports.JavascriptCompiler = require './jscompiler'
compilers.CoffeescriptCompiler = exports.CoffeescriptCompiler = require './cscompiler'

exports.compileFile = (targetFile, sourceFile, options) ->
	throw new Error("#{path.basename sourceFile} not found") unless path.existsSync sourceFile

	options ?= {}

	encoding = options.encoding or 'utf8'
	lint = options.lint or false

	delete options.encoding
	delete options.lint

	[dot, ext] = (path.extname sourceFile).split '.'
	contents = fs.readFileSync sourceFile, encoding

	for own k, compilerClass of compilers
		if compilerClass?.extensions? 
			unless underscore.indexOf(compilerClass.extensions, ext) is -1
				compiler = new compilerClass

	throw new Error("Unknown extension: #{ext}") unless compiler?

	compiler.setOption k, v for own k, v of options
	output = compiler.compile contents

	(reporter.report sourceFile, (compiler.lint sourceFile, output)) if lint

	fs.writeFileSync targetFile, output, 0, encoding
