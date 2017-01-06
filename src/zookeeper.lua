
--
--	@name:	Connnect to the Zookeeper Server
--	@param:	ctx	the Current Context
--
function Connect( ctx )

	zkServerAddr	= ctx.get("zookeeper.server")
	zkUser		= ctx.get("zookeeper.user")
	zkPasswd	= ctx.get("zookeeper.passwd")
	zkTimeout	= ctx['zookeeper.timeout']
	
	if nil == zkServerAddr
	then
		print("zookeeper.server must be set...")
		return false
	else
		status = ZKConnect( zkServerAddr , zkTimeout)
		os.execute("sleep 100")
	end
end

package = {}
package ["zkConnect"] = Connect;


return package

