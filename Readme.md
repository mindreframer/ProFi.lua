## ProFi v1.3, by Luke Perkin 2012. MIT Licence http://www.opensource.org/licenses/mit-license.php.


Origin: https://gist.github.com/perky/2838755

## Example:
  ```lua
    ProFi = require 'ProFi'
    ProFi:start()
    some_function()
    another_function()
    coroutine.resume( some_coroutine )
    ProFi:stop()
    ProFi:writeReport( 'MyProfilingReport.txt' )
  ```

## API:

  Arguments are specified as: type/name/default.

      ProFi:start( string/once/nil )
      ProFi:stop()
      ProFi:checkMemory( number/interval/0, string/note/'' )
      ProFi:writeReport( string/filename/'ProFi.txt' )
      ProFi:reset()
      ProFi:setHookCount( number/hookCount/0 )
      ProFi:setGetTimeMethod( function/getTimeMethod/os.clock )
      ProFi:setInspect( string/methodName, number/levels/1 )
