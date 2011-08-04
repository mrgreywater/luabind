#include <boost/cregex.hpp> 

extern "C"
{
	#include "lua.h"
	#include "lauxlib.h"
	#include "lualib.h"
}

#include <luabind/luabind.hpp>

namespace
{
	bool match(boost::RegEx& r, const char* s)
	{
		return r.Match(s);
	}

	bool search(boost::RegEx& r, const char* s)
	{
		return r.Search(s);
	}
} // namespace unnamed


void wrap_regex(lua_State* L)
{
	using boost::RegEx;
	using namespace luabind;

	module(L)
	[
		class_<RegEx>("regex")
			.def(constructor<const char*>())
			.def(constructor<const char*, bool>())
			.def("match", match)
			.def("search", search)
			.def("what", &RegEx::What)
			.def("matched", &RegEx::Matched)
			.def("length", &RegEx::Length)
			.def("position", &RegEx::Position)
	];
}

int main()
{
#if LUA_VERSION_NUM < 501
	lua_State* L = lua_open();
	lua_baselibopen(L);
	lua_mathlibopen(L);
#else
	lua_State* L = luaL_newstate();
	luaL_openlibs(L);
#endif

	luabind::open(L);
	
	wrap_regex(L);

#if LUA_VERSION_NUM < 501
	lua_dofile(L, "regex.lua");
#else
	luaL_dofile(L, "regex.lua");
#endif
	
	lua_close(L);
}

