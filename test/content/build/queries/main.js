exports.SimpleQuery = function simpleQuery(params) {
	return {
		type: 'hierarchicalrequirement',
		key: 'stories',
		query: '(ScheduleState = "' + params.ScheduleState + '")',
		fetch: 'Name,ScheduleState,Iteration'
	};
};