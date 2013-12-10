package cont;
import haxe.macro.Expr;
import haxe.macro.Context;

class Util {

  // catch Exceptions and pass them to continuation functions
  macro static public function catchCont(cont:Expr, block:Expr):Expr {
    return macro {
      try{
        var r = $block;
        $cont(function(){ return r; });
      }catch(e:Dynamic){
        $cont(function(){ throw e; return null; });
      }
    }
  }
}
