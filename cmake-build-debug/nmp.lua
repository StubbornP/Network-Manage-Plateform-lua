ctx = require "ctx"
zk	= require "zookeeper"
watcher = require "watcher"
completion = require "completion"

ctx.defaultCtx()

zk.zkConnect( ctx )
