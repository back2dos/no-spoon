class Modify {
  static function stuff() {
    no.Spoon.bend('Std', macro class {
      static public inline function answer():Int
        return 42;
    });
    no.Spoon.bend('RunTests', function (fields, cls) {
      switch fields.find('test') {
        case [f]: f.access.push(AStatic);
        default: throw 'assert';
      }
      fields.patch(macro class {
        static function foo() return 'only-new-foo';
        static function bar() return 'only-new-bar';
        static function assert() {}
      }, OnlyNew);


      fields.patch(macro class {
        static var throws = throw 'oops';//this one should not be generated and thus not throw
        static function assert(cond:Bool, ?pos:haxe.PosInfos)
          if (!cond) {
            Sys.println('Assertion failed in ' + pos.className + '@' + pos.lineNumber);
            Sys.exit(500);
          }
      }, OnlyExisting);
    });
  }
}