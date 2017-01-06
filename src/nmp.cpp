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



int init() {

    pMachine = luaL_newstate();

    if( NULL == pMachine){
        return EFAULT;
    }

    pthread_mutex_init(&Machine_Lock,NULL);



    luaL_openlibs( pMachine );

    lua_ctx_init( pMachine );

    lua_zookeeper_init( pMachine );    //Init Zookeeper Connection Module ...
    lua_pcap_init( pMachine );         // Init Pcap Processing Module ...

    return 0;
}

static int opt_routine( __attribute_used__ int argc, __attribute_used__ char** argv){

    //OptGet Code Here!

    return  0;
}

int main(int argc, char** argv){

    opt_routine(argc,argv);

    init();                     // Init the running environment

    int ret = luaL_dofile(pMachine,"./nmp.lua"); // Start the main script

    if( ret ){
        printf("Error in script:\n%s",luaL_checkstring(pMachine,-1));
        exit( -1 );
    }

    while(running){
        releaseMachine();

        sleep(IDEL_PEROID);

        aquireMachine();
    }

    lua_close( pMachine );

    return 0;
}