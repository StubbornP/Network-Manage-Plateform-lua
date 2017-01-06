ctx = require "config"
zk	= require "zookeeper"
watcher = require "watcher"
completion = require "completion"

context.defaultContext()
zk.zkConnect( context )
