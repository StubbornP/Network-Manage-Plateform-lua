--
-- Created by IntelliJ IDEA.
-- User: stubborn
-- Date: 1/7/17
-- Time: 1:19 AM
-- To change this template use File | Settings | File Templates.
--

local package   = {}

local mods      = {}
local running   =   true
local relaxInterval

local function zkModRootStatCallback( param )

    local zkRoot = ctx.get( "modManager.zkRoot" )

    if( 0 == param['exist']) then

        local _,retPath =  zk.create( zkRoot, "", 0, "PUBLIC","PERSISTENT" )

        logger:info( "ZKModRootPath from the zookeeper :"..retPath)
    end
end

local function loadMod( mod )

    local modName           = mod [ 'modName' ]
    local instanceName      = mod [ 'instanceName' ]
    local modPackage        = mod [ 'modPackage' ]
    local initParam         = mod [ 'initParam' ]
    local singleInstance    = mod [ 'singleInstance' ]
    local zkModNode         = ctx.get( "modManager.zkRoot")

    if not ( nil == zkModNode ) then
        zkModNode = zkModNode.."/"..instanceName
    end

    if nil == initParam then
        initParam = {}
    end

    initParam[ 'zkModName'] = modName
    initParam[ 'zkModRoot' ] = zkModNode
    initParam[ 'instanceName'] = instanceName

    for _,v in pairs( mods ) do

        if ( modName == v[ 'modName' ]  and singleInstance == true ) or
                ( modName == v[ 'modName' ] and instanceName == v[ 'instanceName' ] ) then
            logger:warning( " mod Already exist modName:"..modName..","..instanceName )
            return "alreadyExist"
        end
    end

    local ret, _mod_ = pcall(function( pkt ) return require(pkt)  end, modPackage )

    if ret == true then

        mod = _mod_

        local init_proc = mod ['init']

        if init_proc and type( init_proc ) == 'function' then
            local ret, err = pcall(function( initParam ) init_proc ( initParam )  end, initParam )

            if ret then

                table.insert( mods, 1,mod )
                logger:info("Mod init succeed modName:"..modName..","..instanceName)

                return "Ok"
            else
                logger:warn("bad module modName("..modName..","..instanceName.."):init failed,".. err)
                return "init failed"
            end
        else
            logger:warn("bad module modName("..modName..","..instanceName.."):bad module")
            return "bad module"
        end
    else
        logger:warn( "bad module modName("..modName..","..instanceName.."):Faild to load package" )
        return "Faild to load package"
    end
end

local function loadMods( modTable )

    for _, modParam in pairs( modTable ) do

        if modParam['loadOnStartUp'] == true then
            loadMod( modParam )
        end
    end
end

local function unloadMod( instanceName )

    local deInitProc

    for i,mod in pairs( mods )
    do
        if instanceName == mod['instanceName'] then
            deInitProc = mod[ 'deInit' ]

            if not ( not deInitProc ) then
                deInitProc()
            end
            table.remove( mods, i )
        end
    end
end

local function unloadMods()

    local deInitProc
    for i,mod in pairs( mods )
    do
        deInitProc = mod[ 'deInit' ]

        if not ( not deInitProc ) then
            deInitProc()
        end

        table.remove( mods, i )
    end
end

local function ctlMod( paramTable)

    local modName           = paramTable [ 'modName' ]
    local instanceName       = paramTable [ 'instanceName' ]

    for _,v in pairs( mods ) do

        if ( modName == v[ 'modName' ] and instanceName == v[ 'instanceName' ] ) and
            'function' == type( v['ctl'] )
        then

            local ctl = v[ 'ctl' ]
            ctl( paramTable )
        end
    end
end

local function initModManager()

    local zkStart = ctx.get( "zookeeper.enableOnStartup" )
    local zkRoot  = ctx.get( "zookeeper.zookeeperRoot" )
    local modJsonFile = ctx.get( "monManager.modJsonFile" )
    local modJson,modTable

    relaxInterval= ctx.get( "monManager.relaxInterval" )

    logger:info("Reading modJson from file:"..modJsonFile )

    local file = io.open( modJsonFile, "r");

    if( zkStart == true ) then

        local zkModRoot = zkRoot.."/Mod"
        ctx.set("modManager.zkRoot", zkModRoot )

        completion.register( "defaultZKModRootStatCallback", zkModRootStatCallback )
        zk.aExist( zkModRoot, 1, "defaultZKModRootStatCallback" )
    end

    if not file then
        logger:warning( "Error opening modJson file: "..modJsonFile )
    else
        modJson = file:read("*a")
        if not modJson then
            logger:warning( "Error Reading modJson file:"..modJsonFile )
        else
            modTable = json.decode( modJson )

            if not modTable then
                logger:warning( "Error Decoding modJson ... ")
            else
                logger:info( "modJson decoded, now loading them ... ")

                loadMods( modTable)
            end
        end
    end
end

local function shutdownModManager()

    logger:info("modManager unloading mods ... ")

    unloadMods()
    running = false

end

local function modManagerProc()

    local mod_proc
    while running do

        for _,v in pairs( mods )            -- Triggger all the mod_proc
        do
            mod_proc = v['modProc']

            if 'function' == type( mod_proc ) then
                mod_proc()
            end
        end
        relaxMachine( relaxInterval )
    end

end

package ['init']                = initModManager
package ['shutdown']            = shutdownModManager

package ['load']                = loadMod
package ['unload']              = unloadMod

package ['ctl']                 = ctlMod

package ['relaxMachine']        = relaxMachine
package ['monManagerRoutine']   = modManagerProc

return package


