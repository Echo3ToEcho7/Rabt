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
	
	console.log "Creating new Rabt Project..."
	name = argv._[0]
	language = argv.l
	tplPath = path.join __dirname, '..', 'lib', 'templates'
	
	app = fs.readFileSync path.join(tplPath, language, 'app.txt'), 'utf8'
	app = app.replace '@@NAME@@', argv.p + '.' + name.replace(/\ /g, '')
	rootDirName = name.toLowerCase().replace(/\ /g, '_')
	ext = switch language
		when "javascript" then 'js'
		when "coffeescript" then 'coffee'
		when "icedcoffeescript" then 'iced'
	
	console.log "Creating directory structures..."
	mkdirp.sync "./#{rootDirName}/src"
	mkdirp.sync "./#{rootDirName}/stage"
	mkdirp.sync "./#{rootDirName}/build"
	mkdirp.sync "./#{rootDirName}/cache"
	mkdirp.sync "./#{rootDirName}/test"
	mkdirp.sync "./#{rootDirName}/server"
	
	fs.writeFileSync "./#{rootDirName}/src/app.#{ext}", app, 'utf8'
	fs.writeFileSync "./#{rootDirName}/app.jade", fs.readFileSync(path.join(tplPath, 'app.jade'), 'utf8'), "utf8"
	
	cake = """
		fs = require 'fs'
		path = require 'path'
		rabt = require 'rabt'

		option '-u', '--username [username]', 'username to Rally when deploying'
		option '-p', '--password [password]', 'password to Rally when deploying'
		option '-s', '--server [server]', 'Rally server to deploy to.  Default: rally1'
		
		projectOid = 0 #FILL ME IN
		name = '#{name}'

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
			l.setOption 'appName', name
			j = fs.readFileSync './app.jade'
			content = fs.readFileSync './build/app.js'

			fs.writeFileSync './app.html', (l.link j, content)

		task 'deploy', 'deploy the app to a new tab', (options) ->
			invoke 'link'

			content = fs.readFileSync './app.html', 'utf8'
			server = options.server or 'rally1'
			
			unless options.username and options.password
				console.error 'Please provide a username and password to deploy to Rally'
				process.exit -1
				
			unless projectOid > 0
				console.error 'Please provide a project oid in the Cakefile to deploy to Rally'
				process.exit -1
			
			d = new rabt.deploy.Deploy options.username, options.password, server + '.rallydev.com'

			if path.existsSync './appdef.json'
				oids = require './appdef'
				d.updatePage oids.dashboard, oids.panel, projectOid, name, 'myhome', content, () ->
					console.log "Page updated at https://\#{server}.rallydev.com/#/\#{projectOid}d/custom/" + oids.dashboard
			else
				d.createNewPage projectOid, name, content, 'myhome', (doid, poid) ->
					fs.writeFileSync './appdef.json', JSON.stringify {dashboard: doid, panel: poid}
					console.log "Page created at https://\#{server}.rallydev.com/#/\#{projectOid}d/custom/" + doid

	"""
	console.log "Creating Cakefile..."
	fs.writeFileSync "./#{rootDirName}/Cakefile", cake, 'utf8'
	
	console.log "Installing NPM dependencies..."
	npm = exec "cd #{rootDirName} && npm install rabt", (err, stdout, stderr) ->
		console.log stdout
		console.log "NPM dependencies have been installed."
		console.log "Your new Rabt project is ready."
		console.log "Please edit your Cakefile to add the ProjectOID that you will deploy to."
		
	
