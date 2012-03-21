_ = require 'underscore'
jade = require 'jade'

class Linker
	constructor: (options) ->
		@_lOptions = {}
		_.extend @_lOptions, options

		@__defineGetter__ "options", () -> @_lOptions

	setOption: (name, value) -> @_lOptions[name] = value

	getOption: (name) -> @_lOptions[name]

	removeOption: (name) -> delete @_lOptions[name]

	link: (jadeFileContents, compiledJS) ->
		locals = {}
		locals.title = "Test"
		locals.app = "rally.addOnLoad(function onLoad() { #{compiledJS} });"

		fn = jade.compile jadeFileContents
		fn locals

exports.Linker = Linker
