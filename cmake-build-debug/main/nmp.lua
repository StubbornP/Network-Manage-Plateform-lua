logger      = require "main.log"
json 		= require "thirdparty.dkjson"
ctx 		= require "main.ctx"

completion 	= require "main.completion"
watcher 	= require "main.watcher"

pcap     	= require "main.pcap"
monManager  = require "main.modManager"

p0f         = require "modP0F"
nDPI        = require "modNDPI"
cURL        = require "thirdparty.cURL"
env         = ctx.get('env')

ctx.defaultCtx( )

local function defaultPcapWacherCallback( state, _, _ )

    logger:info("PcapWatcher State Changed to: "..state..",Timestamp:"..os.time())

    if state == "CLOSED" then
        logger:info("PCAP CLOSED")
        modNDPIDestory()
        p0f['modP0FDestroy']()
        monManager.shutdown()
    end

end

watcher.Register( "defaultPcap", "pcapModStateChanged",defaultPcapWacherCallback)

local state = pcap.ModStart()

p0f['modP0FInit']("./mod/p0f.fp",pcap['getDataLinkTypeInt']())
modNDPIInit(pcap['getDataLinkTypeInt']())

logger:info("memory "..collectgarbage("count"))

monManager.init()

logger:info("Working ENV Init DONE ... the VM lock will be released ... ")

if "PREPARED" == state then
    pcap.startCap()
end

logger:info( "pcap Mod State:" ..  pcap.getLastError() )

monManager.monManagerRoutine()

pcap.close()

monManager.relaxMachine( 1000000 )

monManager.shutdown()
