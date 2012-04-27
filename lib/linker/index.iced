_ = require 'underscore'
browserify = require 'browserify'
fs = require 'fs'

class Linker
	constructor: (options) ->
		@_bOptions = {}
		_.extend @_bOptions, options

		@__defineGetter__ "options", () -> @_bOptions

	setOption: (name, value) -> @_bOptions[name] = value

	getOption: (name) -> @_bOptions[name]

	removeOption: (name) -> delete @_bOptions[name]

	link: (entryFile, queriesDir) ->
		b = browserify()
		#b.addEntry '../rally/index.iced' if @getOption('test') is true
		b.addEntry entryFile
		b.bundle()

		

exports.Linker = Linker
