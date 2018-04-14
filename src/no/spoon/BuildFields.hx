package no.spoon;

import haxe.macro.Expr;

@:forward(length)
abstract BuildFields(Array<Field>) from Array<Field> to Array<Field> {

  @:arrayAccess inline function get(index:Int)
    return this[index];

  public function remove(filter:FieldFilter):Void {
    
    var i = this.length;
    
    while (i --> 0) {
      var f = this[i];
      if (filter(f)) {
        var last = this.pop();
        if (f != last)
          this[i] = last;
      }
    }
  }

  public function find(filter:FieldFilter):Array<Field>
    return [for (f in this) if (filter(f)) f];

  public function patch(p:FieldPatch, ?k:PatchKind):Array<Field> {

    var map = [for (f in p) f.name => f];

    for (i in 0...this.length)
      switch map[this[i].name] {
        case null:
        case f: 
          map.remove(f.name);
          if (k != OnlyNew) this[i] = f;
      }

    if (k != OnlyExisting)
      for (f in map)
        this.push(f);

    return p;
  }
}

@:enum abstract PatchKind(String) {
  var All = null;
  var OnlyNew = 'OnlyNew';
  var OnlyExisting = 'OnlyExisting';
}

@:forward
abstract FieldPatch(Array<Field>) from Array<Field> to Array<Field> {

  @:from static function fromDefinition(td:TypeDefinition):FieldPatch
    return td.fields;
}

@:callable
abstract FieldFilter(Field->Bool) from Field->Bool {
  @:from static function ofName(s:String):FieldFilter 
    return function (f:Field) return f.name == s;
}