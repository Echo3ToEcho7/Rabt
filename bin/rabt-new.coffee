fs = require 'fs'
path = require 'path'
mkdirp = require 'mkdirp'
exec = require('child_process').exec

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
	
	cake = """
	
		fs = require 'fs'
		path = require 'path'
		rabt = require 'rabt'

		option '-p', '--password', 'password to Rally when deploying'
		option '-u', '--username', 'username to Rally when deploying'
		option '-s', '--server', 'Rally server to deploy to.  Default: rally1'
		
		projectOid = 0 #FILL ME IN

		task 'compile', 'compile the app', (options) ->
			rabt.compiler.compileFile './stage/app.js', './src/app.#{ext}'

		task 'build', 'build the app', (options) ->
			invoke 'compile'

			b = new rabt.builder.Builder

			content = b.build './stage/app.js'
			fs.writeFileSync './build/app.js', content

		task 'link', 'link all the files to create the app', (options) ->
			invoke 'build'

			l = new rabt.linker.Linker
			j = fs.readFileSync './app.jade'
			content = fs.readFileSync './build/app.js'

			fs.writeFileSync './app.html', (l.link j, content)

		task 'deploy', 'deploy the app to a new tab', (options) ->
			invoke 'link'

			content = fs.readFileSync './app.html', 'utf8'

			d = new rabt.deploy.Deploy options.username, options.password, (options.server or 'rally1') + '.rallydev.com'

			if path.existsSync './appdef.json'
				oids = require './appdef'
				d.updatePage oids.dashboard, oids.panel, projectOid, content, (o) ->
					console.log "Page updated at https://demo01.rallydev.com/#/719828d/custom/" + o
			else
				d.createNewPage projectOid, 'Rabt', content, 'myhome', (doid, poid) ->
					fs.writeFileSync './appdef.json', JSON.stringify {dashboard: doid, panel: poid}
					console.log "New page at https://demo01.rallydev.com/#/719828d/custom/" + doid

	"""
	
	fs.writeFileSync "./#{rootDirName}/Cakefile", cake, 'utf8'
	
	npm = exec "cd #{rootDirName} && npm install rabt", (err, stdout, stderr) ->
		console.log stdout
	
