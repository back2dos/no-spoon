package no;

import haxe.macro.Expr;
import haxe.macro.*;
import no.spoon.*;

class Spoon {
  
  static var benders:Array<Bender>;

  static function buildAdhoc(id:Int) {
    
    var fields = Context.getBuildFields(),
        cls = Context.getLocalClass();
    
    benders[id](fields, if (cls == null) null else cls.get());
    
    return fields;
  }

  static public function replace(name:String, type:ComplexType) {
    var parts = name.split('.');
    Context.defineType({
      name: parts.pop(),
      pack: parts,
      pos: (macro null).pos,
      kind: TDAlias(type),
      fields: [],
    });
  }

  static public function bend(name:String, bender:Bender) {
    //TODO: give warning for benders that didn't run
    if (benders == null) {
      benders = [];
      Context.onAfterGenerate(function () benders = null);
    }

    Compiler.addGlobalMetadata(name, '@:build(no.Spoon.buildAdhoc(${benders.push(bender) - 1}))');
  }
}