# `no-spoon` - bend it like Neo!

This library makes it easy to modify/replace existing classes with init macros. Requires at least Haxe 3.2.1.

## Patching fields on existing classes

The simplest possible way is using class reification:

```haxe
no.Spoon.bend('haxe.Timer', macro class {
  static function repeat(rate:Int, f:Void->Void) {
    var t = new haxe.Timer(rate);
    t.run = f;
    return t;
  }
})
```

The second argument to `bend` however is defined to be a `Bender` which is defined like so:

```haxe
abstract Bender from BuildFields->ClassType->Void {
  @:from static function fromDefinition(td:TypeDefinition):Bender;
}

@:forward(length)
abstract BuildFields(Array<Field>) from Array<Field> to Array<Field> {
  @:arrayAccess function get(index:Int):Field;
  public function remove(filter:FieldFilter):Void;
  public function find(filter:FieldFilter):Array<Field>;
  public function patch(p:FieldPatch, ?k:PatchKind):Array<Field>;
}

@:enum abstract PatchKind(String) {
  var All = null;
  var OnlyNew = 'OnlyNew';
  var OnlyExisting = 'OnlyExisting';
}

@:forward
abstract FieldPatch(Array<Field>) from Array<Field> to Array<Field> {
  @:from static function fromDefinition(td:TypeDefinition):FieldPatch;
}

@:callable
abstract FieldFilter(Field->Bool) from Field->Bool {
  @:from static function ofName(s:String):FieldFilter;
}
```

You can provide a function, that operates on `BuildFields` - an abstract, that has a few helpers to ease field manipulation. Example:

```haxe
var fields:BuildFields = ...;
fields.remove('foo');//removes field called `foo` (if it exists)
fields.remove(function (f) return f.access.indexOf(AStatic) == -1);//removes all non static fields

fields.patch(macro class {
  public function foo():Void;
});//will add `foo` to the fields (if `foo` existed before, it is replaced)

fields.patch(macro class {
  public function foo():Void;
}, OnlyNew);//will add `foo` to the fields (if `foo` existed before, nothing is changed)

fields.patch(macro class {
  public function foo():Void;
}, OnlyNew);//will replace `foo` if it exists
```

### Bending caveats

If you call `no.Spoon.bend` after the target type has already been loaded, it will have no effect. If your patching attempts seem to not be applied, make sure you're performing them "early enough".

## Replacing types

Simple example:

```haxe
no.Spoon.replace('Math', macro : FastMath);
```

### Replacement caveats

If you call `no.Spoon.replace` after the target type has already been loaded, you will get a compiler error.

## When to use this library

If the idea of using this library seems a bit naughty to you, then that's because it is. In the vast majority of cases you should use this as a temporary bandaid and try to fix the problem upstream. Of course the upstream source may be slow to release patches (e.g. the stdlib) or somehow obsolete (e.g. abandoned library or the stdlib of an old Haxe version etc.). 

A truly "legitimate" use case is when the changes that you wish to perform are only beneficial in the very narrow use case you're having and outside it would do more harm than good.

To a very large extent, what this library does comes close to monkey patching in JavaScript/Ruby/Python and method swizzling in Objective-C. There's however one crucial benefit of the technique this library allows: the code replacement is performed at compile time and will be processed by static analysis, meaning there is a pretty solid check in place to make sure that the replacement code is not absolute non-sense.

## Alternatives

You can always rely on Haxe's class path shadowing. If you're not happy with how some stdlib or 3rd party code works, you can put a module of the same name into your class path and it will take precedence.

This can be problematic in two ways:

1. You have a whole module to deal with, even though you wanted to alter a single method. You may have to port unrelated upstream patches into your code base. 
2. If it's a haxe core type, then shadowing will also be applied for macros, which rely on the neko/eval implementation. E.g. if you copy the `Std` for js into your class path to modify it, macros that rely on `Std` will fail.

Another advantage of `no-spoon` is, that your changes can be highly granular and context aware:

```haxe
if (haxe_ver >= 4)
  no.Spoon.bend(/* work around some Haxe 4 regression */);
else
  no.Spoon.bend(/* make super useful method that was added in Haxe 4 available today */)
```
