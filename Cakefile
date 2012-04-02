fs = require 'fs'
c = require './lib'

task 'compile', 'compile the app', (options) ->
	c.compiler.compileFile './test/content/build/foo.js', './test/content/src/foo.iced'
	c.compiler.compileFile './test/content/build/bar.js', './test/content/src/bar.iced'
	c.compiler.compileFile './test/content/build/queries/main.js', './test/content/src/queries/main.js'


task 'build', 'build the app', (options) ->
	invoke 'compile'

	b = new c.builder.Builder

	content = b.build './test/content/build/bar.js'
	fs.writeFileSync './test/content/test.comp.js', content

task 'link', 'link all the files to create the app', (options) ->
	invoke 'build'

	l = new c.linker.Linker
	j = fs.readFileSync './test/content/app.jade'
	content = fs.readFileSync './test/content/test.comp.js'

	fs.writeFileSync './test/content/out.html', (l.link j, content)

task 'deploy', 'deploy the app to a new tab', (options) ->
	invoke 'link'

	content = fs.readFileSync './test/content/out.html'

	d = new c.deploy.Deploy "cobrien@rallydev.com", "Just4Rally", "demo01.rallydev.com"
	await d.createNewPage 729766, 'Test', content, 'myhome', defer oid

	console.log "New page create with id #{oid}"