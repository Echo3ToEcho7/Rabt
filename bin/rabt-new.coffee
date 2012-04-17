fs = require 'fs'
path = require 'path'
mkdirp = require 'mkdirp'

opts = require('optimist')
	.usage('Creates a new Rally App\nUsage: rabt new project_name [options]')
	.alias('l', 'language')
	.describe('l', 'Language to use in the App.  Options are javascript, coffeescript, icedcoffeescript')
	.default('l', 'javascript')
	.alias('p', 'package')
	.describe('p', 'Namespace package for your app')
	.default('p', 'app')
	
argv = opts.argv

exports.run = () ->
	if argv._.length isnt 1
		opts.showHelp()
		process.exit  0
	
	name = argv._[0]
	language = argv.l
	tplPath = path.join __dirname, '..', 'lib', 'templates'
	
	app = fs.readFileSync path.join(tplPath, language, 'app.txt'), 'utf8'
	app = app.replace '@@NAME@@', argv.p + '.' + name.replace(' ', '')
	rootDirName = name.toLowerCase().replace(' ', '_')
	ext = switch language
		when "javascript" then 'js'
		when "coffeescript" then 'coffee'
		when "icedcoffeescript" then 'iced'
	
	mkdirp.sync "./#{rootDirName}/src"
	mkdirp.sync "./#{rootDirName}/stage"
	mkdirp.sync "./#{rootDirName}/build"
	
	fs.writeFileSync "./#{rootDirName}/src/app.#{ext}", app, 'utf8'
	fs.writeFileSync "./#{rootDirName}/app.jade", fs.readFileSync(path.join(tplPath, 'app.jade'), 'utf8'), "utf8"
	
	