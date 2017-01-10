local watcherSubscribed = {}

local function connectionWatcher( paramTable )

	local state = paramTable["state_type"]
	local event = paramTable["event_type"]
	local path  = paramTable["path"]

    logger:info("Connection Watcher triggered event:"..event.."\tstate:"..state)

	if event == "UNKNOWN_EVENT_TYPE" then
        logger:warning("UNKNOWN_EVENT_TYPE found!")
	end

	for _,v in pairs( watcherSubscribed )
	do
		if ( not( nil == v or nil == v['callback'] ) ) then

			local cb = v['callback']

			cb( state, event, path )
		end
	end
end

local function regiestWatcher( name, callback )

	local info = {}

	for _,v in pairs( watcherSubscribed )
	do
		if not( nil == v) and v['name'] == name then
			return -1
		end
	end

	info ['name']  = name
	info ['callback']  = callback

	table.insert( watcherSubscribed, 1,info )

	return 0
end

local function unregiestWatcher( name )

	for i,v in pairs( watcherSubscribed )
	do
		if not( nil == v) and v['name'] == name then
			table.remove( watcherSubscribed, i )
		end
	end

	return 0
end

----------------------------------------------------------------------------------

local function defaultConnectionWacherCallback( state, _, _ )

	if state == "CONNECTED_STATE" then
        logger:info("Connection Established Successfully ...")
	elseif state == "AUTH_FAILED_STATE" then
        logger:warning("Authentication failure. Shutting down ...")
	elseif state == "EXPIRED_SESSION_STATE" then
        logger:warning("Session expired. Shutting down ...")
		ZKClose()
	else
        logger:error("Unkown SESSION_EVENT ...")
		ZKClose()
	end
end

local package = {}

package ["connectionWatcher"] 		= connectionWatcher			--	the root Watcher

package ["watcherRegister"] 		= regiestWatcher
package ["watcherUnregister"] 		= unregiestWatcher

local function init()

	regiestWatcher( "defaultConnection", defaultConnectionWacherCallback)

    logger:info("Watcher Mod init finished ... ")
end

init()

return package
