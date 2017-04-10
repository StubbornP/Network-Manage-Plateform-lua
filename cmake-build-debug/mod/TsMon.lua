--
-- Created by IntelliJ IDEA.
-- User: stubborn
-- Date: 1/7/17
-- Time: 2:03 AM
-- To change this template use File | Settings | File Templates.
--

local package = {}

local AUTHOR = "STUBBORN"
local VERSOIN = "1.0"

local commitPackets = 10000

local packets = 0
local state
local error

local lastTimestamp = 0

local helpString = ""
helpString = helpString.."Author:"..AUTHOR.."\n"
helpString = helpString.."VERSON:"..VERSOIN.."\n"
helpString = helpString.."Usage:\n"
helpString = helpString.."\t enable: Enable this mod. \n"
helpString = helpString.."\t disable: Disable this mod. \n"
helpString = helpString.."\t info:  get the info of the mod. \n"

local data = {}

local function packetSubscriber( param, analyseResult)

    local ts = analyseResult['PktTs_sec'];
    local u_ts = analyseResult['PktTs_us'];
    local L2 = analyseResult['L2Protocol'];
    local L3 = analyseResult['L3Protocol'];
    local L4 = analyseResult['L4Protocol'];
    if L4 == "TCP" then

        local Source = analyseResult['IP.Source'];
        local Destination= analyseResult['IP.Destination'];
        local TotalLength= analyseResult['IP.TotalLength'];
        local TTL= analyseResult['IP.TTL'];

        local SourcePort = analyseResult['TCP.SourcePort'];
        local DestinationPort = analyseResult['TCP.DestinationPort'];

        local key = Source..":"..SourcePort.."-"..Destination..":"..DestinationPort

        if nil == data [key] then
            data[key] = {}
        end

        local d = {}
        d[ 'Ts' ] = ts
        d[ 'uTs' ] = u_ts
        d[ 'TotalLength' ] = TotalLength
        d[ 'TTL' ] = TTL
        table.insert( data[key], d )

    end

    packets = packets + 1

    if packets >= commitPackets then

    end

end

local function init( param )

    state = "Raw"

    if not ( nil == param  or nil == param['commitPackets']) then
        commitPackets = param['commitPackets']
    end

    lastTimestamp = os.time()
    pcap.registerSubscriber( "TsMon",  packetSubscriber)

    state = "Enable"
end

local function deInit( _ )
    state = "Closed"
end

local function info( _ )

end

local function ctl( paramTable )

    local cmd = paramTable['cmd']

    if "enable" == cmd then
        state = "Enable"
    elseif "disabled" == cmd then
        state = "Disable"
    elseif "info" == cmd then
        info()
    elseif "help" == cmd then
        logger:info( helpString )
    end
end

local function modProc()

    if not state == "Enable" then
        return
    end

    if( os.time() - lastTimestamp ) > 5 then

        print( json.encode(data))

        data = {}
        packets = 0

        lastTimestamp = os.time()
    end


end

package ['init'] = init
package ['deInit'] = deInit
package ['ctl'] = ctl
package ['help'] = helpString
package ['modProc'] = modProc

return package