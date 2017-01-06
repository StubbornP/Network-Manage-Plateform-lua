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
	ctxSet("zookeeper.schema", "digest:router1:YzRmOTM3NWY5ODM0YjRlN2YwYTUyOGNjNjVjMDU1NzAyYmY1ZjI0YQo=")
	
	ctxSet("pcap.enableOnStartup","true")
	ctxSet("pcap.source","file")
	ctxSet("pcap.path","./test.pcap")
	
	print("Loading Defaul Context ...[DONE]")
end

package["ctx"]			= Context
package["clear"]		= clear
package["defaultCtx"]		= defaultContext
package["get"]			= ctxGet
package["set"]			= ctxSet

return package;
