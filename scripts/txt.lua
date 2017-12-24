
local tmux = require("tmux")
local tab_complete = require("dit.tab_complete")

local errors = nil

function on_ctrl(key)
   if key == "D" then
      tmux.dict()
   elseif key == "N" then
      tmux.newsidepane()
   elseif key == "P" then
      tmux.man()
   end
end

function highlight_file(filename)
   current_file = filename
end

function highlight_line(line, y)
   if errors and errors[y] then
      local out = {}
      for i = 1, #line do out[i] = " " end
      for x, _ in pairs(errors[y]) do
         if x <= #line then
            out[x] = "*"
            local xs = x
            while line[xs]:match("[%w_%->]") do
               out[xs] = "*"
               xs = xs + 1
            end
         end
      end
      return table.concat(out)
   else
      return ""
   end
end

function on_change()
   errors = nil
   return true
end

function on_key(code)
   return tab_complete.on_key(code)
end
