
--
--	@name:	Connnect to the Zookeeper Server
--	@param:	ctx	the Current Context
--
function Connect( ctx )

	zkServerAddr	= ctx.get("zookeeper.server")
	zkUser		= ctx.get("zookeeper.user")
	zkPasswd	= ctx.get("zookeeper.passwd")
	zkTimeout	= ctx.get('zookeeper.timeout')
	
	if nil == zkServerAddr
	then
		print("zookeeper.server must be set...")
		return false
	else
		status = ZKConnect( zkServerAddr , zkTimeout)
		os.execute("sleep 100")
	end
end

function Create( path, data, len, acl_count, acl_string, type_string)

	paramTable = {}
	paramTable ['path'] 		= path
	paramTable ['data'] 		= data
	paramTable ['len'] 		= len
	paramTable ['acl_count'] 	= acl_count
	paramTable ['acl_string'] 	= acl_string
	paramTable ['type_string'] 	= type_string

	ZKCreate( paramTable )

end

package = {}
package ["zkConnect"] = Connect;
package ["zkCreate"]  = Create;


return package

