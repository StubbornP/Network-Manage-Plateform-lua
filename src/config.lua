function ClearContext()
	ContextClear()
	print("Clearing Context ...[DONE]")
end

function defaultContext()
	
	ClearContext()
	ContextSet("system.DeviceType","Router")

	ContextSet("zookeeper.server","localhost:2181")
	ContextSet("zookeeper.user","Router1")
	ContextSet("zookeeper.passwd","ed3eeb1a72d855fcb261d37bf33e8081f7cb475e3fa6bfca86a8f29236778e5c")

	ContextSet("pcap.enableOnStartup","true")
	ContextSet("pcap.source","file")
	ContextSet("pcap.path","./test.pcap")

	t = ContextTable()
	print("Loading Defaul Context ...[DONE]")
end

package = {}
package["clearContext"]		= ClearContext
package["defaultContext"]	= defaultContext
package["get"]			= ContextGet
package["set"]			= ContextSet
package["zookeeper.timeout"]	= 300000		-- ms

return package;
