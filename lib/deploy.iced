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

		tab ?= 'myhome'
		options =
			url: "https://#{@server}/slm/wt/edit/create.sp"
			method: 'POST'
			followAllRedirects: true
			form:
				name: name
				#html: content
				type: 'DASHBOARD'
				timeboxFilter: 'none'
				pid: tab
				editorMode: 'create'
				cpoid: cpoid
				version: 0
			#jar: @cookieJar

		await request options, defer error, results, body
		
		await jsdom.env body, defer errors, window
		oidElt = window.document.getElementsByName 'oid'
		dashboardOid = oidElt?[0]?.value

		options =
			url: "https://#{@server}/slm/panel/getCatalogPanels.sp?cpoid=#{cpoid}&ignorePanelDefOids&gesture=getcatalogpaneldefs&_slug=/custom/#{dashboardOid}"
			method: 'GET'
		
		await request options, defer error, results, body
		
		#fs.writeFileSync "#{process.cwd()}/_test.html", body
		#console.log "Results", results
		#console.log "Body", body
		
		panels = JSON.parse body
		
		for p in panels
			ptoid = p.oid if p.title is "Custom HTML"

		options =
			url: "https://#{@server}/slm/dashboard/addpanel.sp?cpoid=#{cpoid}&_slug=/custom/#{dashboardOid}"
			method: 'POST'
			followAllRedirects: true
			form:
				panelDefinitionOid: ptoid
				col: 0
				index: 0
				dashboardName: "#{tab}#{dashboardOid}"
				gestrure: 'addpanel'
			#jar: @cookieJar

		await request options, defer error, results, body
		#console.log "Error", error

		#fs.writeFileSync "#{process.cwd()}/_test.html", body
		#console.log "Results", results
		#console.log "Body", body

		panelOid = JSON.parse(body).oid
		
		options =
			url: "https://#{@server}/slm/dashboard/changepanelsettings.sp?cpoid=#{cpoid}&_slug=/custom/#{dashboardOid}"
			method: 'POST'
			followAllRedirects: true
			form:
				oid: panelOid
				dashboardName: "#{tab}#{dashboardOid}"
				settings: JSON.stringify {title: name, content: content}
				gestrure: 'changepanelsettings'
			#jar: @cookieJar

		await request options, defer error, results, body
		
		options =
			url: "https://#{@server}/slm/dashboardSwitchLayout.sp?cpoid=#{cpoid}&layout=SINGLE&dashboardName=#{tab}#{dashboardOid}&_slug=/custom/#{dashboardOid}"
			method: 'GET'

		await request options, defer error, results, body

		callback(dashboardOid, panelOid)

	updatePage: (doid, poid, cpoid, name, tab, content, callback) ->
		callback ?= () ->
		await @_login defer err, res, b

		tab ?= 'myhome'

		options =
			url: "https://#{@server}/slm/dashboard/changepanelsettings.sp?cpoid=#{cpoid}&_slug=/custom/#{doid}"
			method: 'POST'
			followAllRedirects: true
			form:
				oid: poid
				dashboardName: "#{tab}#{doid}"
				settings: JSON.stringify {title: name, content: content}
				gestrure: 'changepanelsettings'
			#jar: @cookieJar

		await request options, defer error, results, body

		callback()

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

		callback.call(err, res, body)

exports.Deploy = Deploy