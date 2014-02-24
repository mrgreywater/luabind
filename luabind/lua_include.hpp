// Copyright (c) 2003 Daniel Wallin and Arvid Norberg

// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF
// ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
// TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT
// SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
// ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
// OR OTHER DEALINGS IN THE SOFTWARE.

#ifndef LUABIND_LUA_INCLUDE_HPP_INCLUDED
#define LUABIND_LUA_INCLUDE_HPP_INCLUDED

#ifndef LUABIND_CPLUSPLUS_LUA
extern "C"
{
#endif

    #include "lua.h"
    #include "lauxlib.h"

#ifndef LUABIND_CPLUSPLUS_LUA
}
#endif

#if LUA_VERSION_NUM < 502
# define lua_compare(L, index1, index2, fn) fn(L, index1, index2)
# define LUA_OPEQ lua_equal
# define LUA_OPLT lua_lessthan
# define lua_rawlen lua_objlen
# define lua_pushglobaltable(L) lua_pushvalue(L, LUA_GLOBALSINDEX)
# define lua_getuservalue lua_getfenv
# define lua_setuservalue lua_setfenv
# define LUA_OK 0

//
// The following compatibility functions were taken from lua-compat-5.2
// (Copyright © 2013 Hisham Muhammad), distributed under the MIT license.
// See https://github.com/hishamhm/lua-compat-5.2
//
inline int lua_absindex(lua_State* L, int i)
{
    if (i < 0 && i > LUA_REGISTRYINDEX)
    i += lua_gettop(L) + 1;
    return i;
}

inline void lua_rawsetp(lua_State* L, int i, void* p)
{
    int abs_i = lua_absindex(L, i);
    luaL_checkstack(L, 1, "not enough stack slots");
    lua_pushlightuserdata(L, (void*)p);
    lua_insert(L, -2);
    lua_rawset(L, abs_i);
}

inline void lua_rawgetp(lua_State* L, int i, void* p)
{
    int abs_i = lua_absindex(L, i);
    lua_pushlightuserdata(L, (void*)p);
    lua_rawget(L, abs_i);
}

inline const char *luaL_tolstring(lua_State *L, int idx, size_t *len)
{
  if (!luaL_callmeta(L, idx, "__tostring")) {
    int t = lua_type(L, idx);
    switch (t) {
      case LUA_TNIL:
        lua_pushliteral(L, "nil");
        break;
      case LUA_TSTRING:
      case LUA_TNUMBER:
        lua_pushvalue(L, idx);
        break;
      case LUA_TBOOLEAN:
        if (lua_toboolean(L, idx))
          lua_pushliteral(L, "true");
        else
          lua_pushliteral(L, "false");
        break;
      default:
        lua_pushfstring(L, "%s: %p", lua_typename(L, t),
                                     lua_topointer(L, idx));
        break;
    }
  }
  return lua_tolstring(L, -1, len);
}

#endif // LUA_VERSION_NUM < 502

#endif // LUABIND_LUA_INCLUDE_HPP_INCLUDED
