connectionWatcherSubscriber = {}

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
end

package = {}

package ["ConnectionWatcher"] = ConnectionWatcher

return package
