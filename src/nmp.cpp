//
// Created by stubborn on 1/3/17.
//

#include "types.h"
#include "nmp.h"

int         running   = 1;
lua_State   *pMachine = NULL;
pthread_mutex_t Machine_Lock;

lua_State *aquireMachine(){
    pthread_mutex_lock(&Machine_Lock);
    return pMachine;
}

int releaseMachine(){
    pthread_mutex_unlock(&Machine_Lock);
    return  0;
}

int lua_relaxMachine(lua_State *L ){

    lua_Integer uSec = luaL_checkinteger( L, -1);

    pthread_mutex_unlock(&Machine_Lock);

    usleep( ( __useconds_t )uSec );

    pthread_mutex_lock(&Machine_Lock);

    return 0;
}

void sig_term_handler( int /* n */ ){
    running = 0;
}

int init() {

    pMachine = luaL_newstate();

    if( NULL == pMachine){
        return EFAULT;
    }

    pthread_mutex_init(&Machine_Lock,NULL);

    luaL_openlibs( pMachine );

    lua_register( pMachine, "relaxMachine", lua_relaxMachine);

    luaopen_pack( pMachine );

    lua_ctx_init( pMachine );

    lua_zookeeper_init( pMachine );    //Init Zookeeper Connection Module ...

    lua_pcap_init( pMachine );         // Init Pcap Processing Module ...

    return 0;
}

int deInit(){

    lua_State *L = aquireMachine();

    lua_ctx_deInit( L );
    lua_zookeeper_deInit( L );
    lua_pcap_deInit( L );

    releaseMachine();

    return 0;
}

static int opt_routine( int /* argc*/, char** /* argv */){

    //OptGet Code Here!

    return  0;
}

int main(int argc, char** argv){

    opt_routine(argc,argv);

    init();                     // Init the running environment

    signal( SIGTERM, &sig_term_handler );

    aquireMachine();

    int ret = luaL_dofile(pMachine,"./main/nmp.lua"); // Start the main script

    releaseMachine();

    if( ret ){
        printf("Error in script:\n%s",luaL_checkstring(pMachine,-1));
        exit( -1 );
    }

    while(running){
        usleep(IDEL_PEROID);
    }

    deInit();

    lua_close( pMachine );

    return 0;
}
