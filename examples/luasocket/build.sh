#!/bin/bash

cd "$(dirname $0)"

repo_root="$(pwd)"/../..
lua_src="$repo_root"/lua-5.3.4/src
lua_bin="$lua_src"/lua
luac_bin="$lua_src"/luac

# Create the usual LuaSocket module tree.
mkdir -p lua/socket
for m in socket ltn12 mime; do
    cp "$repo_root"/luasocket/src/$m.lua lua
done
for m in http url tp ftp headers smtp; do
    cp "$repo_root"/luasocket/src/$m.lua lua/socket
done

# Use LuaCC to amalgamate luasocket with our example.
"$lua_bin" \
    "$repo_root"/luacc/bin/luacc.lua \
    -o "$(pwd)"/amalg.lua \
    -i "$(pwd)" \
    -i "$(pwd)"/lua \
    main \
    socket \
    ltn12 \
    mime\
    socket.url \
    socket.headers \
    socket.http

"$luac_bin" amalg.lua
cp luac.out "$repo_root"
