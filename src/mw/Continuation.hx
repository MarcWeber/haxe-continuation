package mw;

import haxe.macro.Expr;
import haxe.macro.Context;

import com.mindrocks.monads.Monad;

// a value wrapped in a callable function so that an exception can be thrown
// instead
typedef LazyVal<X> = Void -> X;

// a continuation function taking a LazyVal as first argument
typedef ContP<X> = (LazyVal<X>) -> Void;

// a function taking a continuation function as parameter
typedef Cont<X> = ContP<X> -> Void;


class Continuation {

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

/* usage

var res2 = 
  Monad.dO({
    a <= read_file("a")
    b <= read_file("b")
    a+b
  });
*/

@:native("Continuation_Monad") class ContinuationM {
  
  macro public static function dO(body : Expr) return
    Monad._dO("ContinuationM", body, Context);
    
  public static function monad<T>(o : T)
    return ContinuationM;
  
  inline public static function ret<T>(x : T) return
    function(cont){ cont(function(){ return x; }); };

  inline public static function fail < T > (e:Dynamic): Cont<T> {
    return function(cont){ cont(function(){ throw e; return null; } ); };
  }
  
  // o >>= f
  // function(cont){ print cont } >>= function(x){ return function(cont){ cont(x+1); } }
  inline public static function flatMap < T, U > (o : Cont<T>, f1 : T -> Cont<U>) : Cont<U> {
    return function(finalCont){
      try{
        o(function(v1){
            var cont2 = f1(v1());
            cont2(finalCont);
        });
      }catch(e:Dynamic){
        ContinuationM.fail(e)(finalCont);
      }
    }
  }

  // o >> f
  inline public static function map < T, U > (o : Cont<T>, f2 : T -> U) : Cont<U> {
    return function(finalCont){
      try{
        o(function(v1){
          finalCont(function(){ return f2(v1()); });
        });
      }catch(e:Dynamic){
        ContinuationM.fail(e)(finalCont);
      }
    }
  }
}
