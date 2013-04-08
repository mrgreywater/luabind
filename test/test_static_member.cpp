// Copyright Ryan Pavlik 2013. Use, modification and distribution is
// subject to the Boost Software License, Version 1.0. (See accompanying
// file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)

#include "test.hpp"
#include <luabind/luabind.hpp>
#include <luabind/operator.hpp>

struct A{
    A() {}
    static const A a;
    static std::string staticMemFun() {
        return "hello from staticMemFun";
    }
};

const A A::a;

std::ostream& operator<<(std::ostream& os, const A&)
{
	os << "A"; return os;
}

void test_main(lua_State* L)
{
    using namespace luabind;

    module(L) [
        class_<A>("A")
        .def(tostring(const_self))
        ///@todo make this work!
        ///.scope[def_readonly("a", &A::a)]
        .scope[def("staticMemFun", &A::staticMemFun)]
    ];

    ///@todo make this work!
    //DOSTRING(L, "assert(tostring(A.a) == 'A')");
    DOSTRING(L, "assert(A.staticMemFun() == 'hello from staticMemFun')");
    
}
