package = "profi"
version = "scm-1"
source = {
   url = "git://github.com/mindreframer/ProFi.lua",
   dir = "ProFi.lua"
}
description = {
   summary  = "A simple lua profiler that works with LuaJIT and prints a pretty report file in columns.",
   homepage = "https://gist.github.com/perky/2838755",
   license = "MIT"
}
dependencies = {
   "lua >= 5.1"
}
build = {
   type = "builtin",
   modules = {
      ProFi = "ProFi.lua"
   }
}
