(function() {
  var Foo;

  Foo = (function() {

    Foo.name = 'Foo';

    function Foo() {}

    return Foo;

  })();

  exports.Foo = Foo;

}).call(this);
