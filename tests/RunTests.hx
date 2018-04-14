package ;

class RunTests {
  function test() {}
  static function main() {
    test();
    assert(Std.answer() == 42);
    assert(foo() == 'foo');
    assert(bar() == 'only-new-bar');
    Sys.println('all good');
    Sys.exit(0);
  }
  
  static function foo() {
    return 'foo';
  }
  
} 