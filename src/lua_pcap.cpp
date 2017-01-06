//
// Created by stubborn on 1/3/17.
//
#include "types.h"
#include "lua_pcap.h"

static int lua_pcap_Hello( lua_State *L ){

    printf("Hello World!");

    lua_pushnil( L );

    return 0;

}

int lua_pcap_init( lua_State *L ){

    lua_register( L, "PCAP_HelloWorld",lua_pcap_Hello);
    return 0;
};