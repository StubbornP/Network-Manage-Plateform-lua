--
-- Created by IntelliJ IDEA.
-- User: stubborn
-- Date: 1/12/17
-- Time: 6:16 AM
-- To change this template use File | Settings | File Templates.
--

local package = {}

local AUTHOR = "STUBBORN"
local VERSOIN = "1.0"
local lastTimestamp = 0
local zkModRoot
local zkPacketCounterNode
local state
local error

local data = {}

data[ 'modName' ]   = 'packetCounter'

local function zkCreateCallback( paramTable )

    for k,v in pairs( paramTable )do
        if type(v) == 'string' or type(v) == 'integer' or type(v) == 'number' then
            print( k,v)
        end
    end
end

local function dataCollector( _, analyseResult)

    local Ts = analyseResult['PktTs_sec']

    if nil == data[ 'data' ][ Ts ] then

        data['data'][Ts] = 0
    end

    data['data'][Ts] = data['data'][Ts] + 1
end

local function init( params )

    lastTimestamp = os.time()

    data[ 'data' ]      = {}
    zkModRoot = params['zkModRoot']

    pcap.registerSubscriber( "packetCounter", dataCollector )

    completion.register( "PacketCounterCreateCallback", zkCreateCallback )

    zkPacketCounterNode = zkModRoot.."/dataNode"

    zk.aCreate( zkModRoot, "", 0, "PUBLIC", "PERSISTENT", "PacketCounterCreateCallback")
    zk.aCreate( zkPacketCounterNode, "", 0, "PUBLIC", "PERSISTENT", "PacketCounterCreateCallback")
end

local function deInit( _ )

    pcap.unregisterSubscriber( "monPacketCounter")

    zk.delete( zkPacketCounterNode, -1 )
    zk.delete( zkModRoot, -1 )

    state = "Closed"
end

local function ctl( paramTable )

    local _ = paramTable['cmd']

    return "Not Implemented"

end

local function modProc()

    if( os.time() - lastTimestamp ) > 5 then

        local json_data = json.encode( data )
        logger:info( json_data  )
        zk.aCreate( zkPacketCounterNode.."/data", json_data, string.len( json_data ), "PUBLIC", "EPHEMERAL_SEQUENTIAL", "PacketCounterCreateCallback")

        data[ 'data' ]      = {}

        lastTimestamp = os.time()
    end
end

package ['init'] = init
package ['deInit'] = deInit
package ['ctl'] = ctl
package ['modProc'] = modProc

return package

