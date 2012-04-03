request = require 'request'
jsdom = require 'jsdom'
fs = require 'fs'

class Deploy
	constructor: (@username, @password, @server) ->
		@server ?= 'rally1.rallydev.com'
		#@cookieJar = request.jar()

	createNewPage: (cpoid, name, content, tab, callback) ->
		callback ?= () ->
		await @_login defer err, res, b

		options =
			url: "https://#{@server}/slm/wt/edit/create.sp"
			method: 'POST'
			followAllRedirects: true
			form:
				name: name
				html: content
				type: 'HTML'
				pid: tab or 'myhome'
				editorMode: 'create'
				cpoid: cpoid
				version: 0
			#jar: @cookieJar

		await request options, defer error, results, body
		#console.log "Error", error

		#fs.writeFileSync "#{process.cwd()}/_test.html", body
		#console.log "Results", results
		#console.log "Body", body
		
		await jsdom.env body, defer errors, window
		oidElt = window.document.getElementsByName 'oid'

		callback(oidElt?[0]?.value)

	updatePage: (oid, cpoid, content, callback) ->
		callback ?= () ->
		await @_login defer err, res, b

		options = 
			url: "https://#{@server}/slm/wt/edit.sp?cpoid=#{cpoid}&oid=#{oid}"
			method: 'GET'
			followAllRedirects: true

		await request options, defer error, results, body

		await jsdom.env body, defer errors, window
		#fs.writeFileSync "#{process.cwd()}/_test.html", body
		version = (window.document.getElementsByName 'version')?[0]?.value

		console.log "Version", version

		options =
			url: "https://#{@server}/slm/wt/edit/update.sp?cpoid=#{cpoid}&oid=#{oid}"
			method: 'POST'
			followAllRedirects: true
			form:
				html: content
				type: 'HTML'
#				pid: tab or 'myhome'
				editorMode: 'edit'
				cpoid: cpoid
				typechange: false
				version: parseInt(version, 10)
			#jar: @cookieJar

		await request options, defer error, results, body
		#fs.writeFileSync "#{process.cwd()}/_test2.html", body

		await jsdom.env body, defer errors, window
		oidElt = window.document.getElementsByName 'oid'

		callback(oidElt?[0]?.value)

	_login: (callback) ->
		callback ?= () ->

		options =
			url: "https://#{@server}/slm/platform/j_platform_security_check.op"
			method: 'POST'
			followAllRedirects: true
			form:
				j_username: @username
				j_password: @password

		await request options, defer err, res, body
		#console.log "Error", err
		#console.log "Results", res
		#console.log "Body", body


		callback.call(err, res, body)

exports.Deploy = Deploy