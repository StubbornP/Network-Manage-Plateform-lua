connectionWatcherSubscriber = {}

--	t = ZKGet_Children( "/", 1)(path, watch?[ 0 | 1])
--	ZKAGet_Children("/",1,"Event1")(path,watch?[0 | 1],CompleteEvent)
--	t = ZKSet_Data("/test","123",4,1)( path,data,len,version)
--	t = ZKASet_Data("/test","123",4,3,"SetDataEvent")
--	ZKAGet_Data("/test",1,"GetDataEvent")(path,watch?[0 | 1],CompleteEvent)
--	ZKSetAuthSchema( ctx.get("zookeeper.authSchema"), ctx.get("zookeeper.authId") )
--	ZKSetDefaultAuthSchema( )
--  ZKAddAuth( ctx.get("zookeeper.authSchema"), ctx.get("zookeeper.authId") )
--  ZKError2String( errno )


function ConnectionWatcher( paramTable )
	state = paramTable["state_type"]
	event = paramTable["event_type"]
	path  = paramTable["path"]

	print("Connection Watcher triggered event:"..event.."\tstate:"..state)

	if event == "SESSION_EVENT" then
		if state == "CONNECTED_STATE" then
			print("Connection Established Successfully ...")
		elseif state == "AUTH_FAILED_STATE" then
			print("Authentication failure. Shutting down ...")
		elseif state == "EXPIRED_SESSION_STATE" then
			print("Session expired. Shutting down ...")
			ZKClose()
		else
			print("Unkown SESSION_EVENT ...")
			ZKClose()
		end
	end

	ZKSetAuth( ctx.get("zookeeper.authSchema"), ctx.get("zookeeper.authDigest") )



end

package = {}

package ["ConnectionWatcher"] = ConnectionWatcher

return package
