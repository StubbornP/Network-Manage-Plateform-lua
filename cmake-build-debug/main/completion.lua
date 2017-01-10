package = {}
meta	= {}

local completionSubscriber = {}

local function completionRoutine( paramTable )

    for _,v in pairs( completionSubscriber )
    do
        if ( not( nil == v or nil == v['callback'] )
            and paramTable['lua_Event'] ==  v ['lua_Event'] ) then

            local cb = v['callback']

            cb( paramTable )
        end
    end
end

local function regiestCompletion( lua_Event, callback )

    local info = {}

    info ['lua_Event']  = lua_Event
    info ['callback']   = callback

    table.insert( completionSubscriber, 1,info )

    return 0
end

local function unregiestCompletion( lua_Event )

    for i,v in pairs( completionSubscriber )
    do
        if not( nil == v) and v['lua_Event'] == lua_Event then
            table.remove( completionSubscriber, i )
        end
    end

    return 0
end

package ['completionRoutine'] = completionRoutine

package ['registerCompletion'] = regiestCompletion
package ['unregisterCompletion'] = unregiestCompletion

local function aclCompletion( paramTable )

    for k,v in pairs( paramTable )
    do
        if type( v ) == "number" or type( v ) == "string" then
            logger:info( ""..k..": "..v)
        end
    end

end

local function init()

    regiestCompletion("AclSetEvent1",aclCompletion)

end

init()

return package
	
