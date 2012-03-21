foo = require './foo'
simpleQuery = require('./queries/main').SimpleQuery

class Bar extends foo.Foo
	constructor: () ->
		@rallyDS ?= new rally.sdk.data.RallyDataSource('__WORKSPACE_OID__', '729766', '__PROJECT_SCOPING_UP__', '__PROJECT_SCOPING_DOWN__')
		@rallyDS.findAll (simpleQuery ScheduleState: 'Defined'), (res) =>
			console.log res
exports.Bar = Bar

b = new Bar