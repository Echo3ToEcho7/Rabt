fs = require 'fs'

Base = require './base'


class JSCompiler extends Base
	compile: (sourceContent) -> sourceContent

JSCompiler.extensions = ['js']

module.exports = JSCompiler