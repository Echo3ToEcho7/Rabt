fs = require 'fs'

Base = require './base'
reporter = require 'jslint/lib/reporter'

class JSCompiler extends Base
	compile: (name, sourceContent) -> 
		l = @lint sourceContent
		reporter.report name or "untitled", l, true, true
		
		sourceContent

JSCompiler.extensions = ['js']

module.exports = JSCompiler