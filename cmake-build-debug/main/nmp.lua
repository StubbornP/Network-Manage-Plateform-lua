logger      = require "main.log"
json 		= require "thirdparty.dkjson"
ctx 		= require "main.ctx"
zk		    = require "main.zookeeper"
watcher 	= require "main.watcher"
completion 	= require "main.completion"

ctx.defaultCtx( )
zk.zkConnect( )

logger:info("Working ENV Init DONE ... the VM Lock will be released ... ")

