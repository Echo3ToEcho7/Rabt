iced = require 'iced-coffee-script'

Base = require './base'

class CoffeeCompiler extends Base
	compile: (name, sourceContent) ->
		iced.compile sourceContent, @options

CoffeeCompiler.extensions = ['coffee', 'iced']

module.exports = CoffeeCompiler