request = require 'request'
jsdom = require 'jsdom'

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
		console.log "Results", results
		#console.log "Body", body
		
		await jsdom.env body, defer errors, window
		oidElt = window.document.getElementsByName 'oid'

		callback(oidElt?[0]?.value)

	updatePage: (oid, content) ->

	_login: (callback) ->
		callback ?= () ->

		options =
			url: "https://#{@server}/slm/platform/j_platform_security_check.op"
			method: 'POST'
			followAllRedirects: true
			form:
				j_username: @username
				j_password: @password
			#body: "j_username=#{@username}&j_password=#{@password}"
			#jar: @cookieJar

		await request options, defer err, res, body
		#console.log "Error", err
		#console.log "Results", res
		#console.log "Body", body


		callback.call(err, res, body)

exports.Deploy = Deploy