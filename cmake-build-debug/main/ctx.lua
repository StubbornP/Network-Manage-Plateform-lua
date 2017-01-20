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

	ctxSet("system.DeviceType","Router")
	ctxSet("system.nickName","MyRouter1")
	ctxSet("system.Id","6ef04ccc-7e49-4086-bc4d-1daec3f5ba01")

	ctxSet("zookeeper.enableOnStartup", false)
	ctxSet("zookeeper.debug", 0)
	ctxSet("zookeeper.timeout", 300000)
	ctxSet("zookeeper.server", "localhost:2181")
	ctxSet("zookeeper.deterministic_conn_order", 1)
	ctxSet("zookeeper.auth", 1 )
	ctxSet("zookeeper.authSchema", "digest")
	ctxSet("zookeeper.authId", "router1:123456")
	ctxSet("zookeeper.authDigest", "router1:yi9VIT6DAFBv0vbvQvtlofAC3o4=")	--	router1:123456

	-->	the way to calc the digest
	-->	Notice	:	echo -n router1:123456 | openssl sha1 -binary | openssl base64
	-->	yi9VIT6DAFBv0vbvQvtlofAC3o4

	ctxSet("pcap.enableOnStartup", true)
	ctxSet("pcap.source", "file")
	ctxSet("pcap.device", "wlp3s0")
	ctxSet("pcap.promisc", 0 );
	ctxSet("pcap.filePath", "./test.pcap")

	ctxSet("monManager.modJsonFile","./main/mod.json")
	ctxSet("monManager.relaxInterval", 10000 )

	logger:info("Loading Defaul Context ...[DONE]")
end

local package = {}

package["ctx"]			= Context
package["clear"]		= clear
package["defaultCtx"]	= defaultContext
package["get"]			= ctxGet
package["set"]			= ctxSet

return package;
