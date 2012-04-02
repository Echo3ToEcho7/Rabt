(function() {
  var Bar, Foo, b, simpleQuery,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Foo = require('./foo').Foo;

  simpleQuery = require('./queries/main').SimpleQuery;

  Bar = (function(_super) {

    __extends(Bar, _super);

    Bar.name = 'Bar';

    function Bar() {
      var _this = this;
      if (this.rallyDS == null) {
        this.rallyDS = new rally.sdk.data.RallyDataSource('__WORKSPACE_OID__', '729766', '__PROJECT_SCOPING_UP__', '__PROJECT_SCOPING_DOWN__');
      }
      this.rallyDS.findAll(simpleQuery({
        ScheduleState: 'Defined'
      }), function(res) {
        return console.log(res);
      });
    }

    return Bar;

  })(Foo);

  exports.Bar = Bar;

  b = new Bar;

}).call(this);
