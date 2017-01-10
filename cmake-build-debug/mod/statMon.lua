local package = {}

local AUTHOR = "STUBBORN"
local VERSOIN = "1.0"

local lastCommit
local commitCycle = 2
local state
local error

local helpString = ""
helpString = helpString.."Author:"..AUTHOR"\n"
helpString = helpString.."VERSON:"..VERSOIN"\n"
helpString = helpString.."Usage:\n"
helpString = helpString.."\t enable: Enable this mod. \n"
helpString = helpString.."\t disable: Disable this mod. \n"
helpString = helpString.."\t info:  get the info of the mod. \n"

local function init( param )

    state = "Raw"

    local cycle = param['commitCycle']

    if not nil == cycle then
        commitCycle = cycle
    end

    lastCommit = os.time()

    state = "Enable"
end

local function deinit( _ )
    state = "Closed"
end

local function info( _ )

end

local function ctl( paramTable )

    local cmd = paramTable['cmd']

    if "enable" == cmd then
        state = "Enable"
    elseif "disabled" == cmd then
        state = "Disable"
    elseif "info" == cmd then
        info()
    end
end

local function modProc()

    state = "Enable"

    if not state == "Enable" then
        return
    end


    local elapsed = os.time() - lastCommit

    if elapsed > commitCycle then

        lastCommit = os.time()

        -- Set ZK node
    end

end

package ['init'] = init
package ['deinit'] = deinit
package ['ctl'] = ctl
package ['help'] = helpString
package ['modProc'] = modProc

return package