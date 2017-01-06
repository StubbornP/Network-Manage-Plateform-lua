cmake_minimum_required(VERSION 3.6)
project(NetworkManagePlateform)

set(CMAKE_CXX_STANDARD 11)

set(SOURCE_FILES src/lua_pcap.cpp include/lua_pcap.h include/types.h src/nmp.cpp include/nmp.h src/lua_zookeeper.cpp include/lua_zookeeper.h include/lua_ctx.h src/lua_ctx.cpp)
add_executable(NetworkManagePlateform ${SOURCE_FILES})
include_directories(./include)

find_library(
        LUALIB
        NAMES lua
        PATHS /usr/lib /usr/local/lib
        )
SET(ZKLIB /usr/local/lib/libzookeeper_mt.so)

target_link_libraries(NetworkManagePlateform ${LUALIB} ${ZKLIB} -lpthread -ldl)
