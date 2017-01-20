
--
--	@name:	Connnect to the Zookeeper Server
--	@param:	ctx	the Current Context
--

local function zkRouterNodeStatCallback( param )

    local zkRoot = ctx.get( "zookeeper.zookeeperRoot" )

    if( 0 == param['exist']) then

        local paramTable = {}
        paramTable ['path'] 		= zkRoot
        paramTable ['data'] 		= ""
        paramTable ['len'] 			= 0
        paramTable ['acl_string'] 	= "PUBLIC"
        paramTable ['type_string'] 	= "PERSISTENT"

        local _, retPath = ZKCreate( paramTable )

        logger:info( "ZkRoot path from the zookeeper :"..retPath)
    end
end

local function Connect( )

	local zkServerAddr	= ctx.get("zookeeper.server")
	local zkTimeout	    = ctx.get('zookeeper.timeout')
	local state

	if nil == zkServerAddr
	then
        logger:error("zookeeper.server must be set...")
		return false
	else
        state = ZKConnect( zkServerAddr , zkTimeout)

        logger:info("Zoo Connection request sent ...[Status: "..ZKError2String( state ).." ] Waiting for 1s ...")

        local auth          = ctx.get("zookeeper.auth")
        local authSchema    = ctx.get("zookeeper.authSchema")
        local authId        = ctx.get("zookeeper.authId")
        local authDigest    = ctx.get("zookeeper.authDigest")
        local Id            = ctx.get("system.Id")

        relaxMachine( 1000000 ) -- here we relax the VM and wait for 1s

        state = ZKState();

        logger:info("Zoo Connection State:"..state ..".")

        if ( "CONNECTED_STATE" == state ) then
            if( auth == 1 ) then

                logger:info("Setting Auth data for Zoo Connection ...")
                ZKAddAuth( authSchema, authId, "defaultAddAuthEvent")
                ZKSetAuthSchema( authSchema, authDigest )
            end
        end

        local zkRoot = "/routers/"..Id

        ctx.set("zookeeper.zookeeperRoot", zkRoot )

        completion.register( "defaultRouterZkCheck", zkRouterNodeStatCallback )

        ZKAExist( zkRoot, 1, "defaultRouterZkCheck" )

	end
end

local function Create( path, data, len, acl_string, type_string)

	local paramTable = {}
	paramTable ['path'] 		= path
	paramTable ['data'] 		= data
	paramTable ['len'] 			= len
	paramTable ['acl_string'] 	= acl_string
	paramTable ['type_string'] 	= type_string

	local retCode, retPath = ZKCreate( paramTable )

	return retCode,retPath
end

local function ACreate( path, data, len, acl_string, type_string, event)

    local paramTable = {}
    paramTable ['path'] 		= path
    paramTable ['data'] 		= data
    paramTable ['len'] 			= len
    paramTable ['acl_string'] 	= acl_string
    paramTable ['type_string'] 	= type_string
    paramTable ['event'] 	    = event

    local retCode, retPath = ZKACreate( paramTable )

    return retCode,retPath
end

local function defaultAclCompletion( paramTable )

    for k,v in pairs( paramTable )
    do
        if type( v ) == "number" or type( v ) == "string" then
            logger:info( ""..k..": "..v)
        end
    end
end

local package = {}

package ["connect"]         = Connect; -- (hostPort, timeout)
package ["close"]           = ZKClose; -- ( )
package ["state"]           = ZKState; -- ( )

package ["create"]          = Create; --  ret, path ( path, data, len, acl_string, type_string )
package ["aCreate"]         = ACreate; -- retCode ( path, data, len, acl_string, type_string, event)

package ["delete"]          = ZKDelete; --  retCode ( path, version )
package ["aDelete"]         = ZKADelete; -- retCode ( path, version, event )

package ["aGet"]            = ZKAGet_Data; --  retCode ( path, version, event )

package ["set"]             = ZKSet_Data; --  statTable ( path, data, len, version )
package ["aSet"]            = ZKASet_Data; -- statTable( path, data, len, version, event )

package ["aExist"]           = ZKAExist; -- retCode ( path, watch,Event)

package ["getChildren"]     = ZKGet_Children; --  table or retCode( path, watch )
package ["aGetChildren"]    = ZKAGet_Children; -- retCode ( path, watch, event)

package ["aSetAcl"]          = ZKASet_Acl; -- retCode ( path, a_version, acl_string, event )

package ["setAuthSchema"]   = ZKSetAuthSchema -- 0 ( schema, id )
package ["resetAuthSchema"] = ZKSetDefaultAuthSchema -- retCode()

package ["addAuth"]         = ZKAddAuth -- retCode ( scheme, cert, event )

package ["error2String"]    = ZKError2String -- errorString ( errCode)

completion.register("defaultAclCompletion",defaultAclCompletion)
return package