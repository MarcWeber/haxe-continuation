package cross;

// a value wrapped in a callable function so that an exception can be thrown
// instead
typedef LazyVal<X> = Void -> X;

// a continuation function taking a LazyVal as first argument
typedef ContP<X> = (LazyVal<X>) -> Void;

// a function taking a continuation function as parameter
typedef Cont<X> = ContP<X> -> Void;

