_ = require 'underscore'
jade = require 'jade'
parser = require("uglify-js").parser
uglify = require("uglify-js").uglify

class Builder
	constructor: (options) ->
		@_lOptions = {}
		_.extend @_lOptions, options

		@__defineGetter__ "options", () -> @_lOptions

	setOption: (name, value) -> @_lOptions[name] = value

	getOption: (name) -> @_lOptions[name]

	removeOption: (name) -> delete @_lOptions[name]

	build: (jadeFileContents, compiledJS) ->

		locals = {}
		
		locals[k] = v for own k, v of @_lOption
		
		locals.appName = @_lOptions.appName or "Untiled Rabt App"
		locals.appSdkVersion = @_lOptions.appSdkVersion or '2.0a'
		locals.appVersion = @_lOptions.appVersion or ("#{(new Date()).getFullYear()}.#{(new Date()).getMonth() + 1}.#{(new Date()).getDate()}")
		locals.buildType = @_lOptions.buildType or 'release'
		locals.minify = @_lOptions.minify or false
		
		if locals.buildType is 'test'
			locals.app = """
			#{compiledJS}
			"""
		else
			if locals.minify
				ast = parser.parse(compiledJS)
				ast = uglify.ast_mangle(ast)
				ast = uglify.ast_squeeze(ast)
				final_code = uglify.gen_code(ast)
			else
				final_code = compiledJS

			locals.app = """
			#{final_code}
			"""

		fn = jade.compile jadeFileContents
		fn locals

exports.Builder = Builder
