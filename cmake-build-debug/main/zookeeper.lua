
--
--	@name:	Connnect to the Zookeeper Server
--	@param:	ctx	the Current Context
--

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

        os.execute("sleep 1")

        state = ZKState();

        logger:info("Zoo Connection State:"..state ..".")

        if ( "CONNECTED_STATE" == state ) then
            if( auth == 1 ) then

                logger:info("Setting Auth data for Zoo Connection ...")

                ZKAddAuth( authSchema, authId, "defaultAddAuthEvent")
                ZKSetAuthSchema( authSchema, authDigest )
            end
        end
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

local package = {}
package ["zkConnect"] = Connect;
package ["zkCreate"]  = Create;

return package

--	t = ZKGet_Children( "/", 1)(path, watch?[ 0 | 1])
--	ZKAGet_Children("/",1,"Event1")(path,watch?[0 | 1],CompleteEvent)
--	t = ZKSet_Data("/test","123",4,1)( path,data,len,version)
--	t = ZKASet_Data("/test","123",4,3,"SetDataEvent")
--	ZKAGet_Data("/test",1,"GetDataEvent")(path,watch?[0 | 1],CompleteEvent)
--	ZKSetAuthSchema( ctx.get("zookeeper.authSchema"), ctx.get("zookeeper.authId") )
--	ZKSetDefaultAuthSchema( )
--  ZKAddAuth( ctx.get("zookeeper.authSchema"), ctx.get("zookeeper.authId") )
--  ZKError2String( errno )
-- ZKSetAuthSchema( ctx.get("zookeeper.authSchema"), ctx.get("zookeeper.authDigest") )
--  ZKAddAuth( ctx.get("zookeeper.authSchema"), ctx.get("zookeeper.authId"),"dummy")
--  ret = ZKASet_Acl("/path1",0,"public","dummy");
--  retCode,path = zk.zkCreate( "/path1","data1",5,"Private","EPHEMERAL")