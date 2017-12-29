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
   local name = buffer:filename()
   if not (name:match("%.cc$") or name:match("%.cpp$") or name:match("%.cxx$")) then
      cmd.run("tmux splitw w3mman -M $(manpath 2>/dev/null) '%s'", token)
   else
      -- XXX assume stdman lookup (not libc ... problematic)
      cmd.run("tmux splitw man '%s'", (token:match('^std::') and token or "std::"..token))
   end
end

function tmux.dict()
   local token = get_context()
   if not token then return end
   cmd.run("tmux splitw 'sdcv -n %s |less'", token)
end

function tmux.new()
   cmd.run("tmux splitw -h dit")
end

--https://github.com/junegunn/fzf/wiki/Examples
function tmux.fzf()
   local filechosen = cmd.run("fzf")
   cmd.run("tmux splitw -h dit %s", filechosen)
end

return tmux
