//
// Created by stubborn on 1/3/17.
//

#include <string.h>
#include <unistd.h>
#include <vector>

#include "nmp.h"

using namespace std;

static clientid_t   myid;
const clientid_t    *id;
static zhandle_t    *zh = NULL;

static char path_buffer[PATH_MAX] ;
static char schema_buf[BUFSIZ];
static char id_buf[BUFSIZ];

ACL acls[5] = {0};

ACL_vector acl_pub = {
        .count  =   1,
        .data   =   &acls[0],
};

ACL_vector acl_prot = {
        .count  =   2,
        .data   =   &acls[1],
};
ACL_vector acl_priv = {
        .count  =   1,
        .data   =   &acls[3],
};

// ----------------------------------- Built-in -----------------------------------

inline int lua_table_set_integer( lua_State *L, const char *key, lua_Integer value){

    lua_pushstring( L, key);
    lua_pushinteger( L, value);
    lua_settable( L, -3);

    return 0;
}

__attribute_used__  inline int lua_table_set_number( lua_State *L, const char *key, lua_Number value){
    lua_pushstring( L, key);
    lua_pushnumber( L, value);
    lua_settable( L, -3);

    return 0;
}

inline int lua_table_set_string( lua_State *L, const char *key, const char *value){

    lua_pushstring( L, key);
    lua_pushstring( L, value);
    lua_settable( L, -3);

    return 0;
}

inline int lua_table_set_string_idx( lua_State *L, int key, const char *value){

    lua_pushinteger( L, key);
    lua_pushstring( L, value);
    lua_settable( L, -3);

    return 0;
}

inline const char *lua_table_get_string( lua_State *L, const char *key){

    const char *ret;

    lua_pushstring( L, key);
    lua_gettable( L, -2);

    ret = luaL_checkstring( L, -1);

    lua_pop( L , 1 );

    return ret;
}

inline const lua_Integer lua_table_get_int( lua_State *L, const char *key){
    lua_Integer  ret;

    lua_pushstring( L, key);
    lua_gettable( L, -2);

    ret = luaL_checkinteger( L, -1);

    lua_pop( L , 1 );

    return ret;
}

inline void lua_push_table_Stat( lua_State *L, const Stat * stat){

    lua_table_set_integer( L, "czxid", stat ->czxid);
    lua_table_set_integer( L, "mzxid", stat ->mzxid);
    lua_table_set_integer( L, "ctime", stat ->ctime);
    lua_table_set_integer( L, "mtime", stat ->mtime);
    lua_table_set_integer( L, "version", stat ->version);
    lua_table_set_integer( L, "cversion", stat ->cversion);
    lua_table_set_integer( L, "aversion", stat ->aversion);
    lua_table_set_integer( L, "ephemeralOwner", stat ->ephemeralOwner);
    lua_table_set_integer( L, "dataLength", stat ->dataLength);
    lua_table_set_integer( L, "numChildren", stat ->numChildren);
    lua_table_set_integer( L, "pzxid", stat ->pzxid);

    return;
}

/**
 *
 * @name state2String
 * @param state int
 * @return pointer to state string
 *
 */

static const char* state2String(int state){

    if (state == 0)
        return "CLOSED_STATE";
    if (state == ZOO_CONNECTING_STATE)
        return "CONNECTING_STATE";
    if (state == ZOO_ASSOCIATING_STATE)
        return "ASSOCIATING_STATE";
    if (state == ZOO_CONNECTED_STATE)
        return "CONNECTED_STATE";
    if (state == ZOO_EXPIRED_SESSION_STATE)
        return "EXPIRED_SESSION_STATE";
    if (state == ZOO_AUTH_FAILED_STATE)
        return "AUTH_FAILED_STATE";

    return "INVALID_STATE";
}

/**
 * @name type2String
 * @param  Event type
 * @return pinter to event type string
 */

static const char* type2String(int state){

    if (state == ZOO_CREATED_EVENT)
        return "CREATED_EVENT";
    if (state == ZOO_DELETED_EVENT)
        return "DELETED_EVENT";
    if (state == ZOO_CHANGED_EVENT)
        return "CHANGED_EVENT";
    if (state == ZOO_CHILD_EVENT)
        return "CHILD_EVENT";
    if (state == ZOO_SESSION_EVENT)
        return "SESSION_EVENT";
    if (state == ZOO_NOTWATCHING_EVENT)
        return "NOTWATCHING_EVENT";

    return "UNKNOWN_EVENT_TYPE";
}

/**
 * @name aclFromString
 * @param  pAclString
 * @return pinter to ACL_vector
 */


ACL_vector *aclFromString( const char * pAclString){

    if( 0 == strcasecmp( pAclString, "Public" ) ){
        return &acl_pub;
    }
    else if(0 == strcasecmp(pAclString, "Protected") ){
        return &acl_prot;
    }
    else if( 0 == strcasecmp(pAclString, "Private") ){
        return &acl_priv;
    }
    else{
        return NULL;
    }

}

int typeFromString(const char *typeString){

    if( 0 == strcasecmp( typeString, "EPHEMERAL" ) ){
        return ZOO_EPHEMERAL;
    }
    else if(0 == strcasecmp(typeString, "EPHEMERAL_SEQUENTIAL") ){
        return ZOO_EPHEMERAL | ZOO_SEQUENCE;
    }
    else if( 0 == strcasecmp(typeString, "PERSISTENT") ){
        return 0;
    }
    else if( 0 == strcasecmp(typeString, "PERSISTENT_SEQUENTIAL") ){
        return 0 | ZOO_SEQUENCE;
    }
    else{
        return -1;
    }

}

// -----------------------------------  Callback  --------------------------------------

void void_completion(int rc, const void *luaCompletionEvent){

    lua_State *pMachine = aquireMachine();              // get the VM with pMachine locked

    lua_getglobal(pMachine,"completion");               // find the watcher table
    lua_pushstring(pMachine,"completionRoutine");
    lua_gettable(pMachine,-2);                          // get the CompletionRoutine function

    lua_newtable( pMachine );                           // build the param table

    lua_table_set_string( pMachine, \
    "completion_type", "voidCompletion");            // set the completion type

    lua_table_set_string( pMachine, "lua_Event", (const char *)luaCompletionEvent ); // set lua_completion event

    lua_table_set_integer( pMachine, "retCode", rc );     // push the retCode of the former procedure

    if( lua_pcall(pMachine,1,0,0) != LUA_OK){                   // procedure call

        const char * pc = lua_tostring(pMachine,-1);            // error occurred
        printf("Error in Completion C wrap[%s,%d]:%s\n",__FILE__,__LINE__,pc);
    };

    lua_pop(pMachine, 1);   // pop the completion table

    releaseMachine();       // release lua VM
}

void string_completion(int rc, const char *value, const void *luaCompletionEvent){

    lua_State *pMachine = aquireMachine();              // get the VM with pMachine locked

    lua_getglobal(pMachine,"completion");               // find the watcher table
    lua_pushstring(pMachine,"completionRoutine");
    lua_gettable(pMachine,-2);                          // get the CompletionRoutine function

    lua_newtable( pMachine );                           // build the param table

    lua_table_set_string( pMachine, \
    "completion_type", "stringCompletion");            // set the completion type

    lua_table_set_string( pMachine, "lua_Event", (const char *)luaCompletionEvent ); // set lua_completion event

    lua_table_set_integer( pMachine, "retCode", rc );     // push the retCode of the former procedure

    lua_table_set_string( pMachine, "data", value );     // push the retCode of the former procedure

    if( lua_pcall(pMachine,1,0,0) != LUA_OK){                   // procedure call

        const char * pc = lua_tostring(pMachine,-1);            // error occurred
        printf("Error in Completion C wrap[%s,%d]:%s\n",__FILE__,__LINE__,pc);
    };

    lua_pop(pMachine, 1);   // pop the completion table

    releaseMachine();       // release lua VM
}

void strings_completion(int rc, const struct String_vector *strings, const struct Stat *stat, const void *luaCompletionEvent){

    lua_State *pMachine = aquireMachine();              // get the VM with pMachine locked

    lua_getglobal(pMachine,"completion");               // find the watcher table
    lua_pushstring(pMachine,"completionRoutine");
    lua_gettable(pMachine,-2);                          // get the CompletionRoutine function

    lua_newtable( pMachine );                           // build the param table

    lua_push_table_Stat( pMachine, stat);               // push stat into the table

    lua_table_set_string( pMachine, \
    "completion_type", "stringsCompletion");            // set the completion type


    lua_table_set_string( pMachine, "lua_Event", (const char *)luaCompletionEvent); // set lua_completion event

    lua_table_set_integer( pMachine, "retCode", rc);     // push the retCode of the former procedure

    lua_pushstring( pMachine, "data");                  // put the children list into the table


    lua_newtable( pMachine );

    for( int i = 0; i < strings -> count ; i ++){
        lua_table_set_string_idx( pMachine, i, strings -> data[i]);
    }

    lua_settable( pMachine, -3);

    if( lua_pcall(pMachine,1,0,0) != LUA_OK){                   // procedure call

        const char * pc = lua_tostring(pMachine,-1);            // error occurred
        printf("Error in Completion C wrap[%s,%d]:%s\n",__FILE__,__LINE__,pc);
    };

    lua_pop(pMachine, 1);   // pop the completion table

    releaseMachine();       // release lua VM
}

void stat_completion(int rc, const struct Stat *stat, const void *luaCompletionEvent){

    lua_State *pMachine = aquireMachine();              // get the VM with pMachine locked

    lua_getglobal(pMachine,"completion");               // find the watcher table
    lua_pushstring(pMachine,"completionRoutine");
    lua_gettable(pMachine,-2);                          // get the CompletionRoutine function

    lua_newtable( pMachine );                           // build the param table

    lua_push_table_Stat( pMachine, stat);               // push stat into the table

    lua_table_set_string( pMachine, \
    "completion_type", "stateCompletion");            // set the completion type

    lua_table_set_string( pMachine, "lua_Event", (const char *)luaCompletionEvent); // set lua_completion event

    lua_table_set_integer( pMachine, "retCode", rc);     // push the retCode of the former procedure

    if( lua_pcall(pMachine,1,0,0) != LUA_OK){                   // procedure call

        const char * pc = lua_tostring(pMachine,-1);            // error occurred
        printf("Error in Completion C wrap[%s,%d]:%s\n",__FILE__,__LINE__,pc);
    };

    lua_pop(pMachine, 1);   // pop the completion table

    releaseMachine();       // release lua VM
}

void data_completion(int rc, const char *value, int value_len,
                     const struct Stat *stat, const void *luaCompletionEvent){

    lua_State *pMachine = aquireMachine();              // get the VM with pMachine locked

    lua_getglobal(pMachine,"completion");               // find the watcher table
    lua_pushstring(pMachine,"completionRoutine");
    lua_gettable(pMachine,-2);                          // get the CompletionRoutine function

    lua_newtable( pMachine );                           // build the param table

    lua_push_table_Stat( pMachine, stat);               // push stat into the table

    lua_table_set_string( pMachine, \
    "completion_type", "dataCompletion");            // set the completion type

    lua_table_set_integer( pMachine, "value_length", value_len);

    lua_table_set_string( pMachine, "value", value);

    lua_table_set_string( pMachine, "lua_Event", (const char *)luaCompletionEvent); // set lua_completion event

    lua_table_set_integer( pMachine, "retCode", rc);     // push the retCode of the former procedure

    if( lua_pcall(pMachine,1,0,0) != LUA_OK){                   // procedure call

        const char * pc = lua_tostring(pMachine,-1);            // error occurred
        printf("Error in Completion C wrap[%s,%d]:%s\n",__FILE__,__LINE__,pc);
    };

    lua_pop(pMachine, 1);   // pop the completion table

    releaseMachine();       // release lua VM
}

void ConnectionWatcher(zhandle_t *zzh, int type, int state, const char *path,
                       __attribute_used__  void* context) {

    const char *event_type = type2String(type);
    const char *state_type = state2String(state);

    if (type == ZOO_SESSION_EVENT && state == ZOO_CONNECTED_STATE) {
        id = zoo_client_id(zzh);
    }

    lua_State *pMachine = aquireMachine();              // get the VM with pMachine locked

    lua_getglobal(pMachine, "watcher");                  // find the watcher table
    lua_pushstring(pMachine, "connectionWatcher");
    lua_gettable(pMachine, -2);                          // get the ConnectionWatcher function

    lua_newtable(pMachine);                             // push the param table as the function argument

    lua_table_set_string(pMachine, "event_type", event_type);  // set args

    lua_table_set_string(pMachine, "state_type", state_type);

    lua_table_set_string(pMachine, "path", path);

    if (lua_pcall(pMachine, 1, 0, 0) != LUA_OK) {                   // procedure call

        const char *pc = lua_tostring(pMachine, -1);            // error occurred
        printf("Error in Connection Watcher C wrap[%s,%d]:%s\n", __FILE__, __LINE__, pc);
    };

    lua_pop(pMachine, 1);   // pop the watcher table

    releaseMachine();       // release lua VM

    return;
}

// -----------------------------------  C API  --------------------------------------

int lua_zookeeper_init(lua_State *L){

    int ret ;

    lua_register( L, "ZKConnect",lua_zookeeper_Connect);                // init build-in functions
    lua_register( L, "ZKClose", lua_zookeeper_Close);
    lua_register( L, "ZKState", lua_zookeeper_zoo_state);

    lua_register( L, "ZKCreate", lua_zookeeper_create);
    lua_register( L, "ZKACreate", lua_zookeeper_acreate);

    lua_register( L, "ZKDelete", lua_zookeeper_delete);
    lua_register( L, "ZKADelete", lua_zookeeper_adelete);

    lua_register( L, "ZKAGet_Data", lua_zookeeper_agetData);

    lua_register( L, "ZKSet_Data", lua_zookeeper_setData);
    lua_register( L, "ZKASet_Data", lua_zookeeper_asetData);

    lua_register( L, "ZKExist", lua_zookeeper_exist);

    lua_register( L, "ZKGet_Children", lua_zookeeper_getChildren);
    lua_register( L, "ZKAGet_Children", lua_zookeeper_agetChildren);

    // lua_register( L, "ZKSet_Acl", lua_zookeeper_setAcl);

    /**
     *
     *  This function is disabled, please use the async version instead
     *  It block the Watcher procedure and I dont known why :-(
     *  maybe it`s related to the pMachine lock
     *
     */

    lua_register( L, "ZKASet_Acl", lua_zookeeper_asetAcl);

    lua_register( L, "ZKSetAuthSchema", lua_zookeeper_setAclSchema);
    lua_register( L, "ZKSetDefaultAuthSchema", lua_zookeeper_setDefaultAclSchema);

    lua_register( L, "ZKAddAuth", lua_zookeeper_addAuth);

    lua_register( L, "ZKError2String", lua_zookeeper_error2String);

    ret = setDefaultAcl();

    return ret;
}

int lua_zookeeper_deinit( __attribute_used__ lua_State *L ){

    int ret = 0;

    ret = zookeeper_Close( zh );

    return ret;
}

const char *zookeeper_zoo_State(){

    int state;

    if( zh != NULL){

        state = zoo_state( zh );
        return state2String(state);
    }
    return NULL;
}

int zookeeper_Close(zhandle_t *zhandle){

    if( NULL != zhandle ){
        zookeeper_close(zhandle);
        zh = NULL;
    }

    memset(&myid,0, sizeof(myid));
    memset(&id,0, sizeof(myid));

    return 0;
}

int setDefaultAcl(){

    acl_pub. data [ 0 ]. id = ZOO_ANYONE_ID_UNSAFE;
    acl_pub. data [ 0 ]. perms = ZOO_PERM_ALL;

    acl_prot. data [ 0 ]. id = ZOO_ANYONE_ID_UNSAFE;
    acl_prot. data [ 0 ]. perms = ZOO_PERM_ALL;

    acl_prot. data [ 1 ]. id = ZOO_ANYONE_ID_UNSAFE;
    acl_prot. data [ 1 ]. perms = ZOO_PERM_ALL;

    acl_priv. data [ 0 ]. id = ZOO_ANYONE_ID_UNSAFE;
    acl_priv. data [ 0 ]. perms = ZOO_PERM_ALL;

    return 0;
}

// -----------------------------------  LUA - C API  --------------------------------------

static int lua_zookeeper_Connect( lua_State * L){

    const char *hostPort = luaL_checkstring( L, -2 );
    lua_Integer   timeout  = luaL_checkinteger( L, -1 );

    if( NULL != zh ){
        lua_pushinteger( L, EALREADY);
    }

    if( ctxGetInteger( L, "zookeeper.debug") == 1 ){
        zoo_set_debug_level( ZOO_LOG_LEVEL_DEBUG );
    }
    else{
        zoo_set_debug_level( ZOO_LOG_LEVEL_INFO );
    }

    if( ctxGetInteger( L, "zookeeper.deterministic_conn_order") == 1 ){
        zoo_deterministic_conn_order(1);    // enable deterministic order
    }

    zh = zookeeper_init( hostPort, ConnectionWatcher, (int) timeout, &myid, 0, 0);

    if (!zh) {
        lua_pushinteger( L, ZINVALIDSTATE);
    }
    else{
        lua_pushinteger( L, 0);
    }

    usleep( 500 );                  // wait for the connection

    return 1;
}

static int lua_zookeeper_Close( lua_State *L){

    zookeeper_Close(zh);

    lua_pushboolean( L, true );
    return 1;
}

static int lua_zookeeper_zoo_state( lua_State *L ){

    const char * pStr = zookeeper_zoo_State();
    if( NULL == pStr ){
        lua_pushnil( L );
    }
    else{
        lua_pushstring( L, pStr);
    }
    return 1;
}

static int lua_zookeeper_create( lua_State *L ){

    if( ! lua_istable( L, -1 ) ){
        lua_pushnil( L );
    }
    else{

        const char * path = lua_table_get_string( L, "path");
        const char * data = lua_table_get_string( L, "data");
        lua_Integer  len  = lua_table_get_int( L, "len");
        const char * acl_string = lua_table_get_string( L, "acl_string");
        const char * type_string = lua_table_get_string( L, "type_string");

        ACL_vector *acl = aclFromString( acl_string );

        int type = typeFromString( type_string );

        if( NULL == zh){
            lua_pushnil( L );
        }else{

            memset( path_buffer, 0, sizeof( path_buffer ));

            lua_Integer ret = zoo_create( zh , path,data, (int) len, acl,type,path_buffer,PATH_MAX);

            lua_pushinteger( L, ret );
            lua_pushstring( L, path_buffer);

        }
    }
    return 2;
}

static int lua_zookeeper_acreate( lua_State *L ){

    if( ! lua_istable( L, -1 ) ){
        lua_pushnil( L );
    }
    else{

        const char * path = lua_table_get_string( L, "path");
        const char * data = lua_table_get_string( L, "data");
        lua_Integer  len  = lua_table_get_int( L, "len");
        const char * acl_string = lua_table_get_string( L, "acl_string");
        const char * type_string = lua_table_get_string( L, "type_string");
        const char * event = lua_table_get_string( L, "event");

        ACL_vector *acl = aclFromString( acl_string );

        int type = typeFromString( type_string );

        if( NULL == zh){
            lua_pushnil( L );
        }else{

            memset( path_buffer, 0, sizeof( path_buffer ));

            lua_Integer ret = zoo_acreate( zh, path, data, ( int ) len, acl, type, &string_completion, event );

            lua_pushinteger( L, ret );
        }
    }
    return 1;
}

static int lua_zookeeper_delete( lua_State *L ){

    const char * path   = luaL_checkstring( L, -2);
    lua_Integer version = luaL_checkinteger( L, -1);

    lua_Integer ret     = ( lua_Integer ) zoo_delete( zh, path, ( int ) version);

    lua_pushinteger( L, ret );

    return 1;
}

static int lua_zookeeper_adelete( lua_State *L ){

    const char * path   = luaL_checkstring( L, -3);
    lua_Integer version = luaL_checkinteger( L, -2);
    const char * event = luaL_checkstring( L, -1);

    lua_Integer ret     = ( lua_Integer ) zoo_adelete( zh, path,  ( int ) version, &void_completion, event);

    lua_pushinteger( L, ret );

    return 1;
}

static int lua_zookeeper_agetData( lua_State *L ){

    const char * path = luaL_checkstring( L, -3 );
    lua_Integer version = luaL_checkinteger( L, -2 );
    const char *event = luaL_checkstring( L, -1 );

    if( NULL == zh){
        lua_pushnil( L );
    }else{

        int ret = zoo_aget( zh, path, (int) version,&data_completion,event );
        lua_pushinteger( L, ret );
    }
    return 1;
}

static int lua_zookeeper_setData( lua_State *L ){

    const char * path = luaL_checkstring( L, -4 );
    const char * data = luaL_checkstring( L, -3 );
    lua_Integer len   = luaL_checkinteger( L, -2);
    lua_Integer version = luaL_checkinteger( L, -1);

    Stat stat;

    if( NULL == zh){
        lua_pushnil( L );
    }else{

        int ret = zoo_set2( zh, path, data, (int) len, (int) version, &stat);

        lua_newtable( L );
        lua_table_set_integer( L, "retCode", ret );
        lua_push_table_Stat( L, &stat);
    }
    return 1;
}

static int lua_zookeeper_asetData( lua_State *L ){

    const char * path = luaL_checkstring( L, -5 );
    const char * data = luaL_checkstring( L, -4 );
    lua_Integer len         = luaL_checkinteger( L, -3 );
    lua_Integer version     = luaL_checkinteger( L, -2 );
    const char *event = luaL_checkstring( L, -1 );

    Stat stat;

    if( NULL == zh){
        lua_pushnil( L );
    }else{

        int ret = zoo_aset( zh, path, data, (int) len, (int) version,&stat_completion,event );

        lua_newtable( L );
        lua_table_set_integer( L, "retCode", ret );
        lua_push_table_Stat( L, &stat);
    }
    return 1;
}

static int lua_zookeeper_exist( lua_State *L ){

    const char * path = luaL_checkstring( L, -2 );
    lua_Integer watch   = luaL_checkinteger( L, -1);

    Stat stat;

    if( NULL == zh){
        lua_pushnil( L );
    }else{

        int ret = zoo_exists( zh,path, ( int ) watch, &stat);

        lua_newtable( L );
        lua_table_set_integer( L, "retCode", ret );
        lua_push_table_Stat( L, &stat);
    }
    return 1;
}

static int lua_zookeeper_getChildren( lua_State *L ){

    String_vector sv;

    const char * path = luaL_checkstring( L, -2 );
    lua_Integer watch = luaL_checkinteger( L, -1 );

    if( NULL == zh){
        lua_pushnil( L );
    }else{

        int ret = zoo_get_children( zh, path, (int) watch, &sv );

        if( ZOK == ret){

            lua_newtable( L );

            for( int i = 0; i < sv.count ; i ++){
                lua_table_set_string_idx( L, i, sv.data[i]);
            }
        }
        else{
            lua_pushinteger( L, ret);
        }
    }

    return 1;
}

static int lua_zookeeper_agetChildren( lua_State *L ){

    const char * path = luaL_checkstring( L, -3 );
    lua_Integer watch = luaL_checkinteger( L, -2 );
    const char * event = luaL_checkstring( L, -1 );

    if( NULL == zh){
        lua_pushnil( L );
    }else{

        int ret = zoo_aget_children2( zh, path, (int) watch, &strings_completion,event);
        lua_pushinteger( L, ret);
    }

    return 1;
}

// Disabled
__attribute_used__ static int lua_zookeeper_setAcl( lua_State *L ){

    const char *path        = luaL_checkstring( L, -3 );
    lua_Integer version     = luaL_checkinteger( L, -2 );
    const char *acl_string  = luaL_checkstring( L, -1 );

    ACL_vector *acl_v = aclFromString( acl_string );

    lua_Integer ret = ( lua_Integer ) zoo_set_acl( zh, path, ( int ) version, acl_v );

    lua_pushinteger( L, ret);

    return 1;
}

static int lua_zookeeper_asetAcl( lua_State *L ){

    const char *path        = luaL_checkstring( L, -4 );
    lua_Integer version     = luaL_checkinteger( L, -3 );
    const char *acl_string  = luaL_checkstring( L, -2 );
    const char *event       = luaL_checkstring( L, -1 );

    ACL_vector *acl_v = aclFromString( acl_string );

    lua_Integer ret = ( lua_Integer ) zoo_aset_acl( zh, path, ( int ) version, acl_v, &void_completion, event );

    lua_pushinteger( L, ret);

    return 1;
}

static int lua_zookeeper_setAclSchema( lua_State *L ){

    const char * schema = luaL_checkstring( L, -2);
    const char * id = luaL_checkstring( L, -1);

    strcpy( schema_buf, schema );
    strcpy( id_buf, id );

    acl_prot. data [ 0 ]. id. id = id_buf;
    acl_prot. data [ 0 ]. id. scheme = schema_buf;
    acl_prot. data [ 0 ]. perms = ZOO_PERM_ALL;

    acl_prot. data [ 1 ]. id = ZOO_ANYONE_ID_UNSAFE;
    acl_prot. data [ 1 ]. perms = ZOO_PERM_READ;

    acl_priv. data [ 0 ]. id. id = id_buf;
    acl_priv. data [ 0 ]. id. scheme = schema_buf;
    acl_priv. data [ 0 ]. perms = ZOO_PERM_ALL;

    lua_pushinteger( L, 0 );

    return 1;
}

static int lua_zookeeper_setDefaultAclSchema( lua_State *L ){

    lua_Integer  ret = setDefaultAcl();

    lua_pushinteger( L, ret );

    return 1;
}

static int lua_zookeeper_addAuth( lua_State *L ){

    int ret;

    size_t cert_size;

    const char *scheme = luaL_checkstring( L, -3);
    const char *cert   = luaL_checklstring( L, -2, &cert_size);
    const char *event  = luaL_checkstring( L, -1);

    ret = zoo_add_auth( zh, scheme,cert,( int ) cert_size, &void_completion, event);

    lua_pushinteger( L, ret);

    return 1;
}

static int lua_zookeeper_error2String( lua_State *L ){

    const char * pstr;

    lua_Integer eno = luaL_checkinteger( L, -1);

    pstr = zerror( ( int ) eno );

    lua_pushstring( L, pstr );

    return 1;
}
