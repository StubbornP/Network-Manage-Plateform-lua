local package = {}

local completionSubscriber = {}

local function completionRoutine( paramTable )

    for _,v in pairs( completionSubscriber )
    do
        if ( not( nil == v) and 'function' == type(v['callback'])
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

    return
end

local function unregiestCompletion( lua_Event )

    for i,v in pairs( completionSubscriber )
    do
        if not( nil == v) and v['lua_Event'] == lua_Event then
            table.remove( completionSubscriber, i )
        end
    end

    return
end

package ['completionRoutine'] = completionRoutine

package ['register'] = regiestCompletion    -- ( event, callback )
package ['unregiser'] = unregiestCompletion -- ( event )

return package
