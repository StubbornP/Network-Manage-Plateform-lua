logger      = require "main.log"
json 		= require "thirdparty.dkjson"
ctx 		= require "main.ctx"
zk		    = require "main.zookeeper"
watcher 	= require "main.watcher"
completion 	= require "main.completion"
pcap     	= require "main.pcap"

ctx.defaultCtx( )

if ctx.get( "system.WorkingMode" ) == "online" then
    zk.zkConnect( )
end

logger:info("Working ENV Init DONE ... the VM Lock will be released ... ")

local function packetProc( paramTable )

    logger:info("Packet_Size:"..paramTable['len'])
    pcap.analysePacket( paramTable['data'], paramTable['len'], nil, nil)

end

ret = pcap.openFile( "./test.pcap" )

-- ret = pcap.openDevice( "wlp3s0", 0 )

err = pcap.getLastError()

print( err )

if "PREPARED" == ret then
    pcap.registerSubscriber("test",packetProc)
    pcap.startCap()
end

print("the current state is:"..pcap.getModState())

for i = 0,100000,1
do
    relaxMachine( 1000000 )
end

print("try to close pcap ")
pcap.close()


