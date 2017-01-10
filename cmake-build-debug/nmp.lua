ctx = require "ctx"
zk	= require "zookeeper"
watcher = require "watcher"
completion = require "completion"

ctx.defaultCtx()

zk.zkConnect( ctx )

os.execute("sleep 2")

ret,realPath= zk.zkCreate("/node","data",4,"Public","EPHEMERAL")

print ( ZKError2String( ret ) )


ZKSetAuthSchema( "digest", "router1:yi9VIT6DAFBv0vbvQvtlofAC3o4=" )

ZKAddAuth( "digest", "router1:123456","AuthAdd")

ret = ZKASet_Acl("/node" , 1 , "Public", "AclSetEvent1")

os.execute("sleep 2")

ret = ZKASet_Acl("/node" , 0 , "Public", "AclSetEvent1")
ret = ZKASet_Acl("/node" , 1 , "Public", "AclSetEvent1")



print ( ZKError2String( ret ) )

ret = pcapOpenDev("wlp3s0",0)
print("pcap:"..ret)

if "Ok" == ret then
    dl = pcapDatalinkType()
    print( dl )
end

print("Woring ENV Init DONE ... the VM Lock will be released ... ")


