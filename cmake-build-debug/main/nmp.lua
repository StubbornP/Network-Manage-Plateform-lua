logger      = require "main.log"
json 		= require "thirdparty.dkjson"
ctx 		= require "main.ctx"

completion 	= require "main.completion"
watcher 	= require "main.watcher"

zk		    = require "main.zookeeper"
pcap     	= require "main.pcap"

monManager  = require "main.modManager"
p0f         = require "modP0F"
nDPI        = require "modNDPI"
cURL        = require "thirdparty.cURL"

p0f['modP0FInit']("./mod/p0f.fp",14)

ctx.defaultCtx( )


local function defaultSessionWacherCallback( state, _, _ )
    if state == "CONNECTED_STATE" then
        logger:info("Connection Established Successfully ...")
    elseif state == "AUTH_FAILED_STATE" then
        logger:warning("Authentication failure. Shutting down ...")
    elseif state == "EXPIRED_SESSION_STATE" then
        logger:warning("Session expired. Shutting down ...")
        zk.Close()
    else
        logger:error("Unkown SESSION_EVENT ...")
        zk.Close()
    end
end

local function defaultPcapWacherCallback( state, _, _ )

    logger:info("PcapWatcher State Changed to: "..state.."Timestamp:"..os.time())
end

watcher.Register( "defaultSession", "SESSION_EVENT",defaultSessionWacherCallback)
watcher.Register( "defaultPcap", "pcapModStateChanged",defaultPcapWacherCallback)

if ctx.get( "zookeeper.enableOnStartup" ) == true then
    zk.connect( )
end

local state = pcap.ModStart()

modNDPIInit(pcap['getDataLinkTypeInt']())

monManager.init()

logger:info("Working ENV Init DONE ... the VM lock will be released ... ")

if "PREPARED" == state then
    pcap.startCap()
end

logger:info( "pcap Mod State:" ..  pcap.getLastError() )

monManager.monManagerRoutine()

pcap.close()
zk.close()

monManager.relaxMachine( 5000000 )

monManager.shutdown()
