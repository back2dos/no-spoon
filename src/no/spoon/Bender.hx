package no.spoon;

import haxe.macro.Type;
import haxe.macro.Expr;

@:callable
abstract Bender(BuildFields->ClassType->Void) from BuildFields->ClassType->Void {
  @:from static function fromDefinition(td:TypeDefinition):Bender {
    return function (fields, _) fields.patch(td);
  }
}