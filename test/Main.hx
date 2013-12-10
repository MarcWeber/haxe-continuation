import cont.Cont;
import cont.ContinuationM;

class Main {

  static public function mock_read_file_ok(filename:String): Cont<String>  {
    return function(cont){
      cont(function () return filename );
    }
  }

  static public function mock_read_file_failure(filename:String): Cont<String> {
    return function(cont){
      cont(function (){ throw "file not found"; return ""; });
    }
  }

  static function main() {
    var ok = false;

    // test 1 file without error
    mock_read_file_ok("file 1")(function(cont){
      if (cont() == "file 1"){
        ok = true;
      }
    });
    if (!ok) throw "test 1 failed";

    // test 2: file with exception
    ok = false;
    mock_read_file_failure("")(function(cont){
      try{
        cont();
      }catch(e:Dynamic){
        ok = true;
      }
    });
    if (!ok) throw "test 2 failed";


    // test 3: monad
    var result = "";
    ContinuationM.dO({
      a <= mock_read_file_ok("a");
      b <= mock_read_file_ok("b");
      return a+b;
    })(function(x){
      result = x();
    });
    if (result != "ab") throw "test 3 failed";


    // test 4: monad, exception
    result = "";
    ContinuationM.dO({
      a <= mock_read_file_failure("a");
      b <= mock_read_file_ok("b");
      return a+b;
    })(function(x){
      try{
        result = x();
      }catch(e:Dynamic){
        result = "passed";
      }
    });
    if (result != "passed") throw "test 4 failed";
  }
}
