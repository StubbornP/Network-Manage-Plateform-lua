package = {}

function clear()
	Context = {}
	print("Clearing Context ...[DONE]")
end

function ctxSet( key, value )

	Context [ key ] = value
end

function ctxGet( key )
	return Context [ key ]
end

function defaultContext()
	
	clear()

	ctxSet("system.DeviceType","Router")

	ctxSet("zookeeper.debug", 0)
	ctxSet("zookeeper.timeout", 300000)
	ctxSet("zookeeper.server", "localhost:2181")
	ctxSet("zookeeper.deterministic_conn_order", 1)
	ctxSet("zookeeper.authSchema", "digest")
    ctxSet("zookeeper.authId", "router1:123456")
	ctxSet("zookeeper.authDigest", "router1:yi9VIT6DAFBv0vbvQvtlofAC3o4=")	--	router1:123456

	-->	the way to calc the digest
	-->	Notice	:	echo -n router1:123456 | openssl sha1 -binary | openssl base64
	-->	yi9VIT6DAFBv0vbvQvtlofAC3o4

	ctxSet("pcap.enableOnStartup","true")
	ctxSet("pcap.source","file")
	ctxSet("pcap.path","./test.pcap")
	
	print("Loading Defaul Context ...[DONE]")
end

package["ctx"]			= Context
package["clear"]		= clear
package["defaultCtx"]	= defaultContext
package["get"]			= ctxGet
package["set"]			= ctxSet

return package;
