--
-- Created by IntelliJ IDEA.
-- User: ubuntu
-- Date: 4/7/17
-- Time: 11:44 PM
-- To change this template use File | Settings | File Templates.
--

local package = {}

local data_logger = require "mod.dummylog"

local AUTHOR = "STUBBORN"
local VERSOIN = "1.0"
local MODNAME = "modMain"

local msg_pool_size = 1
local msg_pool = {}

local host_online       = {}
local host_pkt_bytes    = {}

local host_os           = {}
local host_link           = {}
local host_port         = {}
local host_app_proto    = {}

local data_tag = 'NOT SET'

local function flush_msg( )

    if not( #msg_pool == 0) then
        local pool = msg_pool
        data_logger.eventLog(pool)
    end
    msg_pool = {}
    msg_pool_size = 1
end

local function hostOnlineProc( analyseResult )

    local L3_Proto = analyseResult['L3Protocol']

    if nil == L3_Proto then
        -- logger:warn("L3 Protocol filed not found, skip it...")
        return
    end

    if not( "IP" == L3_Proto ) then
        -- logger:warn("L3 Protocol is not a IP packet,skip it...")
        return
    end

    local function post_host_online_msg( IP, min_ts)

        msg_pool[msg_pool_size] = {}
        msg_pool[msg_pool_size]["type"] = "HOST_ONLINE";
        msg_pool[msg_pool_size]["ip"] = IP;
        msg_pool[msg_pool_size]["min_ts"] = min_ts;
        msg_pool[msg_pool_size]["data-tag"] = data_tag;

        msg_pool_size = msg_pool_size + 1;
    end

    local srcIP = analyseResult['IP.Source']
    local sec   = analyseResult['PktTs_sec']
    local sec_mod_60 = sec - sec % 60

    if nil == host_online[srcIP] then
        host_online[srcIP] = sec_mod_60
        post_host_online_msg(srcIP,sec_mod_60)
    end

    local last_min_ts = host_online[srcIP];

    if last_min_ts == sec_mod_60 then
        return
    end
    host_online[srcIP] = sec_mod_60
    post_host_online_msg(srcIP,last_min_ts)

end

local function hostPacketsBytes( analyseResult )

    local L3_Proto = analyseResult['L3Protocol']

    if nil == L3_Proto then
        -- logger:warn("L3 Protocol filed not found, skip it...")
        return
    end

    if not( "IP" == L3_Proto ) then
        -- logger:warn("L3 Protocol is not a IP packet,skip it..."..L3_Proto)
        return
    end

    local function post_host_pkt_byte_msg( IP, info)

        msg_pool[msg_pool_size] = {}
        msg_pool[msg_pool_size]["type"] = "HOST_PKT_BYTE";
        msg_pool[msg_pool_size]["ip"] = IP;
        msg_pool[msg_pool_size]["ts"] = info['last_sec'];
        msg_pool[msg_pool_size]["bytes_send"] = info['bytes_send'];
        msg_pool[msg_pool_size]["packets_send"] = info['packets_send'];
        msg_pool[msg_pool_size]["bytes_recv"] = info['bytes_recv'];
        msg_pool[msg_pool_size]["packets_recv"] = info['packets_recv'];
        msg_pool[msg_pool_size]["data-tag"] = data_tag;

        msg_pool_size = msg_pool_size + 1;
    end

    local function buildData( where ,sec)
        where ['last_sec']= sec
        where ['bytes_send'] = 0
        where ['packets_send'] = 0
        where ['bytes_recv'] = 0
        where ['packets_recv'] = 0

    end

    local srcIP = analyseResult['IP.Source']
    local dstIP = analyseResult['IP.Destination']
    local sec   = analyseResult['PktTs_sec']

    if nil == host_pkt_bytes[srcIP] then
        host_pkt_bytes[srcIP] = {}
        buildData(host_pkt_bytes[srcIP],sec);
    end

    if nil == host_pkt_bytes[dstIP] then
        host_pkt_bytes[dstIP] = {}
        buildData(host_pkt_bytes[dstIP],sec);
    end

    local length   = analyseResult['PktLen']
    host_pkt_bytes[srcIP] ['bytes_send'] = length + host_pkt_bytes[srcIP] ['bytes_send']
    host_pkt_bytes[srcIP] ['packets_send'] = 1 + host_pkt_bytes[srcIP] ['packets_send']
    host_pkt_bytes[dstIP] ['bytes_recv'] = length + host_pkt_bytes[dstIP] ['bytes_recv']
    host_pkt_bytes[dstIP] ['packets_recv'] = 1 + host_pkt_bytes[dstIP] ['packets_recv']

    local last_ts = host_pkt_bytes[srcIP]['last_sec'];

    if not (last_ts == sec )then
        post_host_pkt_byte_msg( srcIP, host_pkt_bytes[srcIP] )
        buildData(host_pkt_bytes[srcIP],sec);
    end

    local last_ts = host_pkt_bytes[dstIP]['last_sec'];

    if not (last_ts == sec )then
        post_host_pkt_byte_msg( dstIP, host_pkt_bytes[dstIP] )
        buildData(host_pkt_bytes[dstIP],sec);
    end
end

local function hostOS( analyseResult )

    local p0fInfo = analyseResult['p0fInfo']
    local sec   = analyseResult['PktTs_sec']

    if nil == p0fInfo then return end

    local function post_host_os_msg( IP, os, ts,type )
        msg_pool[msg_pool_size] = {}
        msg_pool[msg_pool_size]["type"] = "HOST_OS_DETECT";
        msg_pool[msg_pool_size]["ip"] = IP;
        msg_pool[msg_pool_size]["ts"] = ts;
        msg_pool[msg_pool_size]["os"] = os;
        msg_pool[msg_pool_size]["data-tag"] = data_tag;

        msg_pool_size = msg_pool_size + 1;

    end

    local function post_host_link_msg( IP, link, ts,type )
        msg_pool[msg_pool_size] = {}
        msg_pool[msg_pool_size]["type"] = "HOST_link_DETECT";
        msg_pool[msg_pool_size]["ip"] = IP;
        msg_pool[msg_pool_size]["ts"] = ts;
        msg_pool[msg_pool_size]["link"] = link;
        msg_pool[msg_pool_size]["data-tag"] = data_tag;

        msg_pool_size = msg_pool_size + 1;

    end

    local subject
    local toServer = p0fInfo['toServer']
    local clientAddr = p0fInfo['clientAddress']
    local serverAddr = p0fInfo['serverAddress']
    local os         = p0fInfo['os']
    local link       = p0fInfo['link']

    if toServer == 1 then
        subject = clientAddr
    else
        subject = serverAddr
    end

    if ( os == nil) and (link == nil) then
        return
    end

    local sec_mod_60 = sec - sec % 60

    if (not (os == nil)) then
        if host_os[subject] == nil then
            host_os[subject] = {}
        end
        if host_os[subject] [os] == nil then
            host_os[subject] [os] = sec_mod_60;
            post_host_os_msg( subject, os, sec_mod_60, "TCP_STACK" )
        end

        if not (host_os[subject][os] == sec_mod_60) then
            post_host_os_msg( subject, os,  host_os[subject][os], "TCP_STACK" )
            host_os[subject][os] = sec_mod_60
        end
    end

    local function account_link(sub,link,sec)
        if (not (link == nil)) then
            if host_link[sub] == nil then
                host_link[sub] = {}
            end

            if host_link[sub] [link]== nil then

                host_link[sub] [link] = sec;
                post_host_link_msg( sub, link, sec, "MTU" )
            end

            if not (host_link[sub][link] == sec) then
                post_host_link_msg( sub, link,  host_link[sub][link], "MTU" )
                host_link[sub][link] = sec
            end
        end
    end

    account_link( clientAddr,link,sec_mod_60)
    account_link( serverAddr,link,sec_mod_60)
end

local function hostPortPktByte( analyseResult )

    local L3_Proto = analyseResult['L3Protocol']

    if nil == L3_Proto then
        -- logger:warn("L3 Protocol filed not found, skip it...")
        return
    end

    if not( "IP" == L3_Proto ) then
        -- logger:warn("L3 Protocol is not a IP packet,skip it..."..L3_Proto)
        return
    end

    local function post_host_port_msg( IP, info)

        msg_pool[msg_pool_size] = {}
        msg_pool[msg_pool_size]["type"] = "HOST_PORT_PKT_BYTES";
        msg_pool[msg_pool_size]["ip"] = IP;
        msg_pool[msg_pool_size]["ts"] = info['last_sec'];
        msg_pool[msg_pool_size]["bytes_send"] = info['bytes_send'];
        msg_pool[msg_pool_size]["packets_send"] = info['packets_send'];
        msg_pool[msg_pool_size]["bytes_recv"] = info['bytes_recv'];
        msg_pool[msg_pool_size]["packets_recv"] = info['packets_recv'];
        msg_pool[msg_pool_size]["data-tag"] = data_tag;

        msg_pool_size = msg_pool_size + 1;

    end

    local function buildData( where ,sec)
        where ['last_sec']= sec
        where ['bytes_send'] = {}
        where ['bytes_recv'] = {}
        where ['packets_send'] = {}
        where ['packets_recv'] = {}
    end

    local L4Proto = analyseResult ["L4Protocol"]
    local L4Sport
    local L4Dport

    if L4Proto == "TCP" then
        L4Sport = analyseResult ["TCP.SourcePort"]
        L4Dport = analyseResult ["TCP.DestinationPort"]
    elseif L4Proto == "UDP" then
        L4Sport = analyseResult ["UDP.SourcePort"]
        L4Dport = analyseResult ["UDP.DestinationPort"]
    else
        return
    end

    local srcIP = analyseResult['IP.Source']
    local dstIP = analyseResult['IP.Destination']
    local sec   = analyseResult['PktTs_sec']

    if nil == host_port[srcIP] then
        host_port[srcIP] = {}
        buildData(host_port[srcIP],sec);
    end

    if nil == host_port[dstIP] then
        host_port[dstIP] = {}
        buildData(host_port[dstIP],sec);
    end

    if nil == host_port[srcIP] ['bytes_send'][L4Sport] then
        host_port[srcIP] ['bytes_send'][L4Sport] = 0
        host_port[srcIP] ['packets_send'][L4Sport] = 0
    end

    if nil == host_port[dstIP] ['bytes_recv'][L4Dport] then
        host_port[dstIP] ['bytes_recv'][L4Dport] = 0
        host_port[dstIP] ['packets_recv'][L4Dport] = 0
    end

    local length   = analyseResult['PktLen']
    host_port[srcIP] ['bytes_send'][L4Sport] = length + host_port[srcIP] ['bytes_send'][L4Sport]
    host_port[srcIP] ['packets_send'][L4Sport] = 1 + host_port[srcIP] ['packets_send'][L4Sport]
    host_port[dstIP] ['bytes_recv'][L4Dport] = length + host_port[dstIP] ['bytes_recv'][L4Dport]
    host_port[dstIP] ['packets_recv'][L4Dport] = 1 + host_port[dstIP] ['packets_recv'][L4Dport]

    local last_ts = host_port[srcIP]['last_sec'];

    if not (last_ts == sec )then
        post_host_port_msg( srcIP, host_port[srcIP] )
        buildData(host_port[srcIP],sec);
    end

    local last_ts = host_port[dstIP]['last_sec'];

    if not (last_ts == sec )then
        post_host_port_msg( dstIP, host_port[dstIP] )
        buildData(host_port[dstIP],sec);
    end
end

local function hostAppPktByte( analyseResult )

    local nDPI = analyseResult['ndpiInfo']

    if nil == nDPI then return end
    if 0 == nDPI['detected.app_protocol'] then return end

    local detected_proto    = nDPI['detected.protocol.name']
    local packet_bytes      = nDPI['bytes']
    local packet_count      = nDPI['packets']
    local ts_sec            = analyseResult['PktTs_sec']

    local function post_host_app_msg( host, proto,ts)

        msg_pool[msg_pool_size] = {}
        msg_pool[msg_pool_size]["type"] = "HOST_APP_PKT_BYTE";
        msg_pool[msg_pool_size]["ip"] = host;
        msg_pool[msg_pool_size]["ts"] = ts;
        msg_pool[msg_pool_size]["proto"] = proto;
        msg_pool[msg_pool_size]["data-tag"] = data_tag;

        msg_pool_size = msg_pool_size + 1;
    end

    local function buildHostAppData( host, ts)

        if nil == host_app_proto[host] then
            host_app_proto[host] = {}
            host_app_proto[host]['ts'] = ts;
            host_app_proto[host]['protos'] = {}
        end
    end

    local function setHostProtoInfo( host, proto, packets, bytes, sec)

        if sec == host_app_proto[host]['ts'] then

            if nil == host_app_proto[host]['protos'][proto] then
                host_app_proto[host]['protos'][proto] = {}
                host_app_proto[host]['protos'][proto]['packets'] = 0
                host_app_proto[host]['protos'][proto]['bytes'] = 0
            end

            host_app_proto[host]['protos'][proto]['packets'] = packets
                    + host_app_proto[host]['protos'][proto]['packets']
            host_app_proto[host]['protos'][proto]['bytes'] = bytes
                    + host_app_proto[host]['protos'][proto]['bytes']
        else

            post_host_app_msg(host,host_app_proto[host]['protos'],host_app_proto[host]['ts'] )
            host_app_proto[host]['ts'] = sec
            host_app_proto[host]['protos'] = {}
        end
    end

    local host_a            = nDPI['host_a.name']
    local host_b            = nDPI['host_b.name']
    buildHostAppData(host_a,ts_sec)
    buildHostAppData(host_b,ts_sec)

    setHostProtoInfo( host_a, detected_proto,packet_count,packet_bytes,ts_sec)

end

local function hostHTTPUA( analyseResult)

    if not ( nil == analyseResult['HTTP.UA']) then

        local ua                = analyseResult['HTTP.UA']
        local ts_sec            = analyseResult['PktTs_sec']

        local function post_host_os_msg( IP, ua, ts,type )
            msg_pool[msg_pool_size] = {}
            msg_pool[msg_pool_size]["type"] = "HOST_UA_PROCESS"
            msg_pool[msg_pool_size]["ip"] = IP
            msg_pool[msg_pool_size]["ts"] = ts
            msg_pool[msg_pool_size]["ua"] = ua
            msg_pool[msg_pool_size]["data-tag"] = data_tag

            msg_pool_size = msg_pool_size + 1
        end
    end

end

local function hostHTTPBUG( analyseResult)

    local srcIP             = analyseResult['IP.Source']
    local ts_sec            = analyseResult['PktTs_sec']
    local ts_sec_mod60      = ts_sec - ts_sec % 60

    local function post_host_bug_msg( host, bug,ts)

        msg_pool[msg_pool_size] = {}
        msg_pool[msg_pool_size]["type"] = "HOST_BUGFIX"
        msg_pool[msg_pool_size]["ip"] = host
        msg_pool[msg_pool_size]["ts"] = ts
        msg_pool[msg_pool_size]["bug"] = bug

        msg_pool_size = msg_pool_size + 1
    end

    local bug = analyseResult['HTTP.BUGFIX']

    if not ( nil == bug ) then
        post_host_bug_msg( srcIP, bug, ts_sec_mod60 )
    end
end

local function dataCollector( _, analyseResult)

    hostOnlineProc(analyseResult)
    hostPacketsBytes(analyseResult)
    hostOS(analyseResult)
    hostPortPktByte(analyseResult)
    hostAppPktByte(analyseResult)
    hostHTTPUA(analyseResult)
    hostHTTPBUG(analyseResult)

    flush_msg()
end

local function GCOnClose(state, _, _ )

    data_logger.flushAll()
    if state == "CLOSED" then
        logger:info("modMainGC")

        msg_pool = nil
        host_online       = nil
        host_pkt_bytes    = nil
        host_os           = nil
        host_link         = nil
        host_port         = nil
        host_app_proto    = nil
        logger:info("memory "..collectgarbage("count"))
        collectgarbage("collect")
        logger:info("memory "..collectgarbage("count"))
    end
end

local function init( _ )

    data_tag = ctx.get('pcap.data-tag')
    data_logger.init()
    pcap.registerSubscriber( "mainDataCollector", dataCollector )
    watcher.Register( "modMainGC", "pcapModStateChanged",GCOnClose)
end

local function deInit( _ )
    data_logger.deInit()
    pcap.unregisterSubscriber( "mainDataCollector")
end

local function ctl( paramTable )

    local _ = paramTable['cmd']

    return "ADD MOD CTL HERE"

end

local function modProc()
    -- mod main proc
end

package ['init'] = init
package ['deInit'] = deInit
package ['ctl'] = ctl
package ['modProc'] = modProc

return package
