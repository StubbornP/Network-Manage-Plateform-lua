cmake_minimum_required(VERSION 2.8)
project(NetworkManagePlateform)

set(CMAKE_CXX_STANDARD 11)

set(SOURCE_FILES src/lua_pcap.cpp src/lua_zookeeper.cpp src/lua_ctx.cpp src/nmp.cpp
        include/lua_ctx.h include/lua_pcap.h include/lua_zookeeper.h include/nmp.h include/types.h ./src/lpack.c include/lua_lpack.h)
add_executable(NetworkManagePlateform ${SOURCE_FILES})
include_directories(./include)

find_library(
        ZK
        NAMES zookeeper
        PATHS /usr/lib /usr/local/lib
)
SET(ZKLIB /usr/local/lib/libzookeeper_mt.so)

find_library(
        LUALIB
        NAMES lua
        PATHS /usr/lib /usr/local/lib
        )
SET(ZKLIB /usr/local/lib/libzookeeper_mt.so)

target_link_libraries(NetworkManagePlateform ${LUALIB} ${ZKLIB} -lpthread -ldl -lpcap)
