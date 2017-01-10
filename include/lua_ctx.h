//
// Created by stubborn on 1/4/17.
//

#ifndef NETWORKMANAGEPLATEFORM_LUA_CONTEXT_H
#define NETWORKMANAGEPLATEFORM_LUA_CONTEXT_H

#include "types.h"
#include "nmp.h"

/**
 * @name ctxGetString
 *
 * @details get a string from the current context ( without locking VM)
 * @param
        *      lua_State L
        *      const char * key
 * @return  pointer to the string ( NULL if not exist)
 */
const char *ctxGetString( lua_State *L, const char *key );

/**
 * @name ctxGetNumber
 *
 * @details get a Number from the current context ( without locking VM)
 * @param
        *      lua_State L
        *      const char * key
 * @return  the number ( -1 if not exist )
 */

lua_Number ctxGetNumber( lua_State *L, const char *key );

/**
 * @name ctxGetInteger
 *
 * @details get a Integer from the current context ( without locking VM)
 * @param
        *      lua_State L
        *      const char * key
 * @return  the integer ( -1 if not exist )
 */

lua_Integer ctxGetInteger( lua_State *L, const char *key );

/**
 * @name ctxGetStringL
 *
 * @details lock the VM and get a String from the current context
 * @param
        *      lua_State L
        *      const char * key
 * @return  pointer to the string ( NULL if not exist )
 */

const char *ctxGetStringL( const char *key );

/**
 * @name ctxGetNumberL
 *
 * @details lock the VM and get a Number from the current context
 * @param
        *      lua_State L
        *      const char * key
 * @return  the number ( -1 if not exist )
 */

lua_Number ctxGetNumberL( const char *key );

/**
 * @name ctxGetIntegerL
 *
 * @details lock the VM and get a Integer from the current context
 * @param
        *      lua_State L
        *      const char * key
 * @return  the integer ( -1 if not exist )
 */

lua_Integer ctxGetIntegerL(const char *key );

/**
 * @name ctxSetString
 *
 * @details set a String to the current context
 * @param
        *      lua_State L
        *      const char * key
        *      const char * value
 * @return  0
 */

int ctxSetString( lua_State *L, const char *key, const char * value);

/**
 * @name ctxSetNumber
 *
 * @details set a Number to the current context ( without locking VM )
 * @param
        *      lua_State L
        *      const char * key
        *      lua_Number value
 * @return  0
 *
 */

int ctxSetNumber( lua_State *L, const char *key, lua_Number value);

/**
 * @name ctxSetInteger
 *
 * @details set a Integer to the current context ( without locking VM )
 * @param
        *      lua_State L
        *      const char * key
        *      lua_Integer value
 * @return  0
 *
 */

int ctxSetInteger( lua_State *L, const char *key, lua_Integer value);

/**
* @name ctxSetStringL
*
* @details lock the VM and set a String to the current context
* @param
        *      lua_State L
        *      const char * key
        *      const char * value
        * @return  0
*
*/

int ctxSetStringL( const char *key, const char * value);

/**
* @name ctxSetNumberL
*
* @details lock the VM and set a Number to the current context
* @param
        *      lua_State L
        *      const char * key
        *      lua_Number value
* @return  0
*
*/

int ctxSetNumberL( const char *key, lua_Number value);

/**
* @name ctxSetIntegerL
*
* @details lock the VM and set a Integer to the current context
* @param
        *      lua_State L
        *      const char * key
        *      lua_Integer value
* @return  0
*
*/

int ctxSetIntegerL( const char *key, lua_Integer value);

/**
* @name lua_ctx_init
*
* @details init the ctx for the lua VM
* @param
        *      lua_State L
        *
* @return  0
*
*/

int lua_ctx_init( lua_State *L);

/**
* @name lua_ctx_deinit
*
* @details deinit the ctx for the lua VM
* @param
        *      lua_State L
        *
* @return  0
*
*/

int lua_ctx_deInit( lua_State *L);

#endif //NETWORKMANAGEPLATEFORM_LUA_CONTEXT_H
