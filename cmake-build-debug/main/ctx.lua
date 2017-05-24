
local function clear()
	Context = {}
	logger:info("Clearing Context ...[DONE]")
end

local function ctxSet( key, value )

	Context [ key ] = value
end

local function ctxGet( key )
	return Context [ key ]
end

local function defaultContext()
	
	clear()

--	ctxSet("system.DeviceType","Router")
--	ctxSet("system.nickName","MyRouter1")
--	ctxSet("system.Id","6ef04ccc-7e49-4086-bc4d-1daec3f5ba01")

--	ctxSet("zookeeper.enableOnStartup", false)
--	ctxSet("zookeeper.debug", 0)
--	ctxSet("zookeeper.timeout", 300000)
--	ctxSet("zookeeper.server", "localhost:2181")
--	ctxSet("zookeeper.deterministic_conn_order", 1)
--	ctxSet("zookeeper.auth", 1 )
--	ctxSet("zookeeper.authSchema", "digest")
--	ctxSet("zookeeper.authId", "router1:123456")
--	ctxSet("zookeeper.authDigest", "router1:yi9VIT6DAFBv0vbvQvtlofAC3o4=")	--	router1:123456

-->	the way to calc the digest
-->	Notice	:	echo -n router1:123456 | openssl sha1 -binary | openssl base64
-->	yi9VIT6DAFBv0vbvQvtlofAC3o4

	if nil == env then
		logger:error('Env not set ...')
		os.exit(1)
	end

	local env_json,_,err = json.decode(env)

	if nil == env_json then
		logger:error('Env decode failed:'..err)
		os.exit(0)
	end
	if 'device' == env_json['mode'] then
		ctxSet("pcap.source", "device")

		if	nil == env_json['device'] then
			logger:error('device not set')
			os.exit(0)
		else
			ctxSet("pcap.device", env_json['device'])
		end
	else
		ctxSet("pcap.source", "file")
		if	nil == env_json['fname'] then
			logger:error('Pcap file not set')
			os.exit(0)
		else
			ctxSet("pcap.filePath", env_json['fname'])
		end
	end

	if nil == env_json['data-tag'] then
		ctxSet("pcap.data-tag", "NOT SET")
	else
		ctxSet("pcap.data-tag", env_json['data-tag'])
	end

	ctxSet("pcap.promisc", 0 )
	ctxSet("pcap.enableOnStartup", true)
	ctxSet("monManager.relaxInterval", 10000 )
	ctxSet("monManager.modJsonFile","./main/mod.json")

--	ctxSet("pcap.source", "file")
--	ctxSet("pcap.device", "ens33")
--	ctxSet("pcap.filePath", "/mnt/hgfs/D/test.pcap")
--	ctxSet("pcap.filePath", "./test.pcap")
--	ctxSet("pcap.filePath", "./test_pcap.pcap")

	logger:info("Loading Defaul Context ...[DONE]")
end

local package = {}

package["ctx"]			= Context
package["clear"]		= clear
package["defaultCtx"]	= defaultContext
package["get"]			= ctxGet
package["set"]			= ctxSet

return package;
