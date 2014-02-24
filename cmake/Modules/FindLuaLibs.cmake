# Locate Lua library
# This module defines
#  LUA52_FOUND, if false, do not try to link to Lua
#  LUA_LIBRARIES
#  LUA_INCLUDE_DIR, where to find lua.h
#  LUA_VERSION_STRING, the version of Lua found (since CMake 2.8.8)
#
# Note that the expected include convention is
#  #include "lua.h"
# and not
#  #include <lua/lua.h>
# This is because, the lua location is not standardized and may exist
# in locations other than lua/

#=============================================================================
# CMake - Cross Platform Makefile Generator
# Copyright 2007-2009 Kitware, Inc.
#
# Adjusted for Lua 5.2 (from 5.1) by Christian Neumüller
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# * Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
#
# * Neither the names of Kitware, Inc., the Insight Software Consortium,
#   nor the names of their contributors may be used to endorse or promote
#   products derived from this software without specific prior written
#   permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#=============================================================================

FIND_PATH(LUA_INCLUDE_DIR lua.h
  HINTS
  ENV LUA_DIR
  PATH_SUFFIXES include/luajit-2.0 include/lua52 include/lua5.2 include/lua-5.2 include/lua51 include/lua5.1 include/lua-5.1 include/lua include
  PATHS
  ~/Library/Frameworks
  /Library/Frameworks
  /sw # Fink
  /opt/local # DarwinPorts
  /opt/csw # Blastwave
  /opt
)

if(LUA_USE_STATIC_LIBS)
  set( _LUA_ORIG_CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_FIND_LIBRARY_SUFFIXES})
  if(WIN32)
    set(CMAKE_FIND_LIBRARY_SUFFIXES .lib .a ${CMAKE_FIND_LIBRARY_SUFFIXES})
  else()
    set(CMAKE_FIND_LIBRARY_SUFFIXES .a ${CMAKE_FIND_LIBRARY_SUFFIXES})
  endif()
endif()

FIND_LIBRARY(_LUA_LIBRARY_RELEASE
  NAMES luajit-5.1 lua52 lua5.2 lua-5.2 lua51 lua5.1 lua-5.1 lua
  HINTS
  ENV LUA_DIR
  PATH_SUFFIXES lib64 lib
  PATHS
  ~/Library/Frameworks
  /Library/Frameworks
  /sw
  /opt/local
  /opt/csw
  /opt
)

FIND_LIBRARY(_LUA_LIBRARY_DEBUG
  NAMES lua52-d lua5.2-d lua-5.2-d lua51-d lua5.1-d lua-5.1-d lua-d
  HINTS
  ENV LUA_DIR
  PATH_SUFFIXES lib64 lib
  PATHS
  ~/Library/Frameworks
  /Library/Frameworks
  /sw
  /opt/local
  /opt/csw
  /opt
)

IF(_LUA_LIBRARY_RELEASE OR _LUA_LIBRARY_DEBUG)
  IF(_LUA_LIBRARY_RELEASE AND _LUA_LIBRARY_DEBUG)
    SET(_LUA_LIBRARY optimized ${_LUA_LIBRARY_RELEASE}
                     debug     ${_LUA_LIBRARY_DEBUG})
  ELSEIF(_LUA_LIBRARY_RELEASE)
    SET(_LUA_LIBRARY ${_LUA_LIBRARY_RELEASE})
  ELSE()
    SET(_LUA_LIBRARY ${_LUA_LIBRARY_DEBUG})
  ENDIF()

  IF(UNIX AND NOT APPLE)
    FIND_LIBRARY(_LUA_MATH_LIBRARY m)
    mark_as_advanced(_LUA_MATH_LIBRARY)
  ENDIF(UNIX AND NOT APPLE)
   # For Windows and Mac, don't need to explicitly include the math library
ENDIF()

if(LUA_USE_STATIC_LIBS)
  set(CMAKE_FIND_LIBRARY_SUFFIXES ${_LUA_ORIG_CMAKE_FIND_LIBRARY_SUFFIXES})
endif()

IF(_LUA_LIBRARY)
    SET(LUA_LIBRARIES
        "${_LUA_LIBRARY}" "${_LUA_MATH_LIBRARY}" CACHE STRING "Lua Libraries")
ENDIF(_LUA_LIBRARY)

if(LUA_INCLUDE_DIR AND EXISTS "${LUA_INCLUDE_DIR}/lua.h")
  file(STRINGS "${LUA_INCLUDE_DIR}/lua.h" lua_version_str REGEX "^#define[ \t]+LUA_RELEASE[ \t]+\"Lua .+\"")

  string(REGEX REPLACE "^#define[ \t]+LUA_RELEASE[ \t]+\"Lua ([^\"]+)\".*" "\\1" LUA_VERSION_STRING "${lua_version_str}")
  unset(lua_version_str)

  # the above does not work for Lua 5.2
  if(LUA_VERSION_STRING STREQUAL "")
    file(STRINGS "${LUA_INCLUDE_DIR}/lua.h" lua_version_str REGEX "^#define[ \t]+LUA_VERSION_MAJOR[ \t]+\".+\"")
    string(REGEX REPLACE "^#define[ \t]+LUA_VERSION_MAJOR[ \t]+\"([^\"]+)\".*" "\\1" lua_version_major "${lua_version_str}")

    file(STRINGS "${LUA_INCLUDE_DIR}/lua.h" lua_version_str REGEX "^#define[ \t]+LUA_VERSION_MINOR[ \t]+\".+\"")
    string(REGEX REPLACE "^#define[ \t]+LUA_VERSION_MINOR[ \t]+\"([^\"]+)\".*" "\\1" lua_version_minor "${lua_version_str}")

    file(STRINGS "${LUA_INCLUDE_DIR}/lua.h" lua_version_str REGEX "^#define[ \t]+LUA_VERSION_RELEASE[ \t]+\".+\"")
    string(REGEX REPLACE "^#define[ \t]+LUA_VERSION_RELEASE[ \t]+\"([^\"]+)\".*" "\\1" lua_version_release "${lua_version_str}")

    set(LUA_VERSION_STRING "${lua_version_major}.${lua_version_minor}.${lua_version_release}")
    unset(lua_version_major)
    unset(lua_version_minor)
    unset(lua_version_release)
  endif()
endif()


INCLUDE(${CMAKE_ROOT}/Modules/FindPackageHandleStandardArgs.cmake)
# handle the QUIETLY and REQUIRED arguments and set LUA_FOUND to TRUE if
# all listed variables are TRUE
FIND_PACKAGE_HANDLE_STANDARD_ARGS(LuaLibs
                                  REQUIRED_VARS LUA_INCLUDE_DIR LUA_LIBRARIES
                                  VERSION_VAR LUA_VERSION_STRING)

MARK_AS_ADVANCED(LUA_INCLUDE_DIR LUA_LIBRARIES LUA_LIBRARY LUA_MATH_LIBRARY
                 _LUA_LIBRARY_RELEASE _LUA_LIBRARY_DEBUG)
