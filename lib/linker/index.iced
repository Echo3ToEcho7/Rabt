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
		locals.appName = @_lOptions.appName or "Untiled Rabt App"
		locals.appSdkVersion = @_lOptions.appSdkVersion
		locals.appVersion = @_lOptions.appVersion or ("#{(new Date()).getFullYear()}.#{(new Date()).getMonth() + 1}.#{(new Date()).getDate()}")
		locals.app = "#{compiledJS}"

		fn = jade.compile jadeFileContents
		fn locals

exports.Linker = Linker
