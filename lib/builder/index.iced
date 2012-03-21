_ = require 'underscore'
browserify = require 'browserify'
fs = require 'fs'
eyes = require 'eyes'

class Builder
	constructor: (options) ->
		@_lOptions = {}
		_.extend @_lOptions, options

		@__defineGetter__ "options", () -> @_lOptions

	setOption: (name, value) -> @_lOptions[name] = value

	getOption: (name) -> @_lOptions[name]

	removeOption: (name) -> delete @_lOptions[name]

	build: (entryFile, queriesDir) ->
		b = browserify()
		b.addEntry '../rally/index.iced' if @getOption('test') is true
		b.addEntry entryFile
		b.bundle()

		

exports.Builder = Builder
