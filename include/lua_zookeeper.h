//
// Created by stubborn on 1/3/17.
//

#ifndef NETWORKMANAGEPLATEFORM_LUA_ZOOKEEPER_H
#define NETWORKMANAGEPLATEFORM_LUA_ZOOKEEPER_H

#include "types.h"
#include "zookeeper/zookeeper.jute.h"

//--------------------------- C API -------------------------------

/**
 * lua_zookeeper_init
 *
 * @details luaZookeeper MoD init
 * @param   lua VM state
 *
 * @return  error code ( 0 if no error )
 */

int lua_zookeeper_init(lua_State *L);

/**
 * lua_zookeeper_deinit
 *
 * @details luaZookeeper MoD deinit
 * @param   lua VM state
 *
 * @return  error code ( 0 if no error )
 */

int lua_zookeeper_deinit(lua_State *L);

/**
 * zookeeper_zoo_State
 *
 * @details return the state string of current zookeeper connection
 * @param   null
 *
 * @return  pointer to the string ( NULL if connection not init)
 */

const char* zookeeper_zoo_State();

/**
 * zookeeper_Close
 *
 * @details close the zookeeper connection and reset the variables
 * @param   null
 *
 * @return  0
 */

int zookeeper_Close(zhandle_t *zhandle);

/**
 * setDefaultAcl
 *
 * @details reset the Acl Schema
 * @param   null
 *
 * @return  0
 */

int setDefaultAcl( );

//--------------------------- LUA API -----------------------------

static int lua_zookeeper_Connect( lua_State *L);

/**
 * lua_zookeeper_Close
 *
 * @details Zookeeper Close API
 * @param lua VM state ( no lua param)
 * @return num arguments
 */

static int lua_zookeeper_Close( lua_State *L);

/**
 * lua_zookeeper_zoo_state
 *
 * @details lua API for fetching the Zookeeper Connection State
 * @param lua VM state (no lua param)
 * @return num arguments
 */

static int lua_zookeeper_zoo_state( lua_State *L);

/**
 * lua_zookeeper_create
 *
 * @details create a node
 * @param lua VM state
    * ( lua_param_1: argTable )
 * @return num arguments
    * ( lua_param_1: retCode, lua_param_2: realPath )
 */

static int lua_zookeeper_create( lua_State *L );

/**
 * lua_zookeeper_acreate
 *
 * @details create a node ( async)
 * @param lua VM state
    * ( lua_param_1: argTable )
 * @return num arguments
    * ( lua_param_1: retCode )
 */

static int lua_zookeeper_acreate( lua_State *L );

/**
 * lua_zookeeper_delete
 *
 * @details delete a node
 * @param lua VM state
    * ( lua_param_1: path, lua_param_2: version )
 * @return num arguments
    * ( lua_param_1: retCode )
 */

static int lua_zookeeper_delete( lua_State *L );

/**
 * lua_zookeeper_delete
 *
 * @details delete a node
 * @param lua VM state
    * ( lua_param_1: path, lua_param_2: version, lua_param_3: event )
 * @return num arguments
    * ( lua_param_1: retCode )
 */

static int lua_zookeeper_adelete( lua_State *L );

/**
 * lua_zookeeper_agetData
 *
 * @details get data of a node ( async )
 * @param lua VM state
    * ( lua_param_1: path, lua_param_2: version, lua_param_3: event )
 * @return num arguments
    * ( lua_param_1: retCode, lua_param_2: realPath )
 */

static int lua_zookeeper_agetData( lua_State *L );

/**
 * lua_zookeeper_setData
 *
 * @details set data for a node
 * @param lua VM state
 *        ( lua_param_1: path,lua_param_2: data,lua_param_3:len,lua_param_4:version)
 * @return num arguments
 */

static int lua_zookeeper_setData( lua_State *L );

/**
 * lua_zookeeper_asetData
 *
 * @details async set data for a node
 * @param lua VM state
 * ( lua_param_1: path,lua_param_2: data,lua_param_3:len,lua_param_4:version,lua_param_5:luaEvent)
 * @return num arguments
 */

static int lua_zookeeper_asetData( lua_State *L );

/**
 * lua_zookeeper_agetChildren
 *
 * @details get all children of a node
 * @param lua VM state
 *        ( lua_param_1: path, lua_param_2: watcher?[ 0 | 1] )
 * @return num arguments
 */

static int lua_zookeeper_getChildren( lua_State *L );

/**
 * lua_zookeeper_getaChildren
 *
 * @details get all children of a node
 * @param lua VM state
 *        ( lua_param_1: path, lua_param_2: watcher?[ 0 | 1], lua_param_3:completion_event )
 * @return num arguments
 */

static int lua_zookeeper_agetChildren( lua_State *L );

/**
 * lua_zookeeper_setAcl
 *
 * @details set privicy for a node
 * @param lua VM state
    * ( lua_param_1: path, lua_param_2: version, lua_param_3: acl_string )
 * @return num arguments
    * ( lua_param_1: retCode )
 */

static int lua_zookeeper_setAcl( lua_State *L );

/**
 * lua_zookeeper_asetAcl
 *
 * @details set privicy for a node( async )
 * @param lua VM state
    * ( lua_param_1: path, lua_param_2: version, lua_param_3: acl_string, lua_param_4: event )
 * @return num arguments
    * ( lua_param_1: retCode )
 */

static int lua_zookeeper_asetAcl( lua_State *L );

/**
 * lua_zookeeper_setAclSchema
 *
 * @details set privilages for Public , Protect and Private
 * @param lua VM state
    * ( lua_param_1: schema, lua_param_2: id )
 * @return num arguments
    * ( lua_param_1: retCode )
 */

static int lua_zookeeper_setAclSchema( lua_State *L );

/**
 * lua_zookeeper_setDefaultAclSchema
 *
 * @details reset the privlage of Public , Protect and Private to world:everyone
 * @param lua VM state
    * ( lua_param_1: schema, lua_param_2: id )
 * @return num arguments
    * ( lua_param_1: retCode )
 */

static int lua_zookeeper_setDefaultAclSchema( lua_State *L );

/**
 * lua_zookeeper_addAuth
 *
 * @details add auth to current connection
 * @param lua VM state
    * ( lua_param_1: schema, lua_param_2: cert, lua_param_3: event )
 * @return num arguments
    * ( lua_param_1: retCode )
 */

static int lua_zookeeper_addAuth( lua_State *L );

/**
 * lua_zookeeper_error2String
 *
 * @details get error string of errno
 * @param lua VM state
    * ( lua_param_1: errno )
 * @return num arguments
    *( lua_param_1: error string )
 */

static int lua_zookeeper_error2String( lua_State *L);

#endif //NETWORKMANAGEPLATEFORM_LUA_ZOOKEEPER_H
