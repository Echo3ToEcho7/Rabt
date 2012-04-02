_ = require 'underscore'
linter = require 'jslint/lib/linter'

class Compiler
	constructor: (options) ->
		@_cOptions = {}
		_.extend @_cOptions, options

		@__defineGetter__ "options", () -> @_cOptions

	setOption: (name, value) -> @_cOptions[name] = value

	getOption: (name) -> @_cOptions[name]

	removeOption: (name) -> delete @_cOptions[name]

	compile: (sourceContent) ->

	lint: (name, sourceContent) ->
		lint = linter.lint sourceContent, {}
		lint



module.exports = Compiler
