//
// Created by stubborn on 1/3/17.
//
#include "types.h"
#include "lua_pcap.h"

pcap_t *pcap = NULL;
int pcap_running;

#define TIME_OUT_WAIT 0

char errbuf [PCAP_ERRBUF_SIZE];

static int lua_pcap_Hello( lua_State *L ){

    printf("Hello World!");

    lua_pushnil( L );

    return 0;

}

void pcap_handle_proc(u_char *, const struct pcap_pkthdr *,
                             const u_char *){




}

int pcap_process(){

    int ret;

    if( NULL == pcap)
        return EINVAL;

    while( pcap_running ){

        ret = pcap_dispatch( pcap,1, &pcap_handle_proc, NULL);

        if( ret == 0 )
            break;



    }



}


static int lua_pcap_open_dev( lua_State *L ){

    const char *dev = luaL_checkstring( L, -2);
    const lua_Integer promisc = luaL_checkinteger( L, -1);

    if( pcap != NULL ){
        lua_pushstring( L, "Already opened!");
    }
    else{
        pcap = pcap_open_live( dev , BUFSIZ, ( int ) promisc, TIME_OUT_WAIT,errbuf);

        if( NULL == pcap){
            lua_pushstring( L, errbuf);
        }
        else{
            lua_pushstring( L, "Ok");
            pcap_running = 1;
        }
    }
    return 1;
}

static int lua_pcap_close( lua_State *L){

    if( NULL != pcap ){
        pcap_close( pcap );
    }

    lua_pushstring( L, "Ok");

    return 1;
}

static int lua_pcap_datalink( lua_State *L){

    int dl;
    const char * dl_name;

    if( NULL == pcap){
        lua_pushnil( L );
    }
    else{
        dl = pcap_datalink(pcap);
        dl_name = pcap_datalink_val_to_name( dl );
        lua_pushstring( L, dl_name );
    }

    return 1;
}

static int lua_pcap_inject( lua_State *L){

    const char *data = luaL_checkstring( L, -2);
    const lua_Integer sz = luaL_checkinteger( L, -1);

    if( NULL == pcap){
        lua_pushstring( L, "Dev not open" );
    }
    else{
        pcap_inject(pcap, data, ( size_t ) sz);
        lua_pushstring( L, "Ok");
    }

    return 1;
}

int lua_pcap_init( lua_State *L ){

    lua_register( L, "PCAP_HelloWorld",lua_pcap_Hello);
    lua_register( L, "pcapOpenDev",lua_pcap_open_dev);
    lua_register( L, "pcapClose", lua_pcap_close);
    lua_register( L, "pcapInject", lua_pcap_inject);
    lua_register( L, "pcapDatalinkType",lua_pcap_datalink);

    return 0;
};