//
// Created by stubborn on 1/3/17.
//

#ifndef NETWORKMANAGEPLATEFORM_LUA_ZOOKEEPER_H
#define NETWORKMANAGEPLATEFORM_LUA_ZOOKEEPER_H

#include "types.h"
#include "zookeeper/zookeeper.jute.h"

//--------------------------- C API -------------------------------

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

//--------------------------- LUA API -----------------------------

/**
 * lua_zookeeper_init
 *
 * @details luaZookeeper MoD init
 * @param   lua VM state
 *          Context the current running context
 *
 * @return  error code ( 0 if no error )
 */

int lua_zookeeper_init(lua_State *L);

/**
 * lua_zookeeper_Connect
 *
 * @details Zookeeper Connect API
 * @param lua VM state ( lua_param_1: host_port,lua_param_2: timeout )
 * @return num arguments
 */

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
 * lua_zookeeper_getChildren
 *
 * @details get all children of a node
 * @param lua VM state
 *        ( lua_param_1: path, lua_param_2: watcher?[ 0 | 1] )
 * @return num arguments
 */

static int lua_zookeeper_getChildren( lua_State *L );

/**
 * lua_zookeeper_getChildren
 *
 * @details get all children of a node
 * @param lua VM state
 *        ( lua_param_1: path, lua_param_2: watcher?[ 0 | 1], lua_param_3:completion_event )
 * @return num arguments
 */

static int lua_zookeeper_agetChildren( lua_State *L );

/**
 * lua_zookeeper_setDate
 *
 * @details set data for a node
 * @param lua VM state
 *        ( lua_param_1: path,lua_param_2: data,lua_param_3:len,lua_param_4:version)
 * @return num arguments
 */

static int lua_zookeeper_setDate( lua_State *L );

/**
 * lua_zookeeper_asetDate
 *
 * @details async set data for a node
 * @param lua VM state
 * ( lua_param_1: path,lua_param_2: data,lua_param_3:len,lua_param_4:version,lua_param_5:luaEvent)
 * @return num arguments
 */

static int lua_zookeeper_asetDate( lua_State *L );



static int lua_zookeeper_Exist( lua_State *L);

static int lua_zookeeper_Acl( lua_State *L );


#endif //NETWORKMANAGEPLATEFORM_LUA_ZOOKEEPER_H
