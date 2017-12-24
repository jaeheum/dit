local tmux = {}

local cmd = require("cmd")

local function get_context()
   local token, x, y, len = buffer:token()
   if not token then return end
   return token
end

function tmux.man()
   local token = get_context()
   if not token then return end
   cmd.run("tmux splitw w3mman '%s'", token)
end

function tmux.dict()
   local token = get_context()
   if not token then return end
   cmd.run("tmux splitw 'sdcv -n %s |less'", token)
end

function tmux.newsidepane()
   local token = get_context()
   if not token then return end
   cmd.run("tmux splitw -h dit '%s'", token)
end

return tmux
