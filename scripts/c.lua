
local cscope = require("cscope")
local tmux = require("tmux")
local code = require("dit.code")
local tab_complete = require("dit.tab_complete")

local current_file = nil
local errors = nil

local function open_header()
   local name = buffer:filename()
   if name:match("%.c$") then
      name = name:gsub("%.c$", ".h")
   elseif name:match("%.h$") then
      name = name:gsub("%.h$", ".c")
   else
      return
   end
   local page = tabs:open(name)
   tabs:markJump()
   tabs:setPage(page)
end

local function popup_error()
   local _, x, y = buffer:token()
   if errors[y] then
      for ex, err in pairs(errors[y]) do
         if x == ex then
            buffer:draw_popup({err})
            return
         end
      end
   end
end

function on_ctrl(key)
   if key == "D" then
      cscope.go_to_definition()
   elseif key == "H" then
      open_header()
   elseif key == "N" then
      tmux.new()
   elseif key == "O" then
      tmux.fzf() -- line_commit.line_commit()
   elseif key == "P" then
      tmux.man()
   elseif key == "R" then
      popup_error()
   elseif key == "_" then
      code.comment_block("//")
   end
end

function on_fkey(key)
   if key == "F7" then
      code.expand_selection()
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

function on_save()
   local name = buffer:filename()
   local cc -- = ""
   if name:match("%.c$") then
      cc = "clang --std=c99"
   elseif name:match("%.cpp$") or name:match("%.cc$") or name:match("%.cxx$") then
      cc = "clang++ --std=c++11"
   else
      return 
   end
   local cmd = io.popen("LANG=C "..cc.." -I. -Ieditorconfig/include -c "..current_file.." 2>&1")
   local cmdout = cmd:read("*a")
   cmd:close()
   errors = {}
   for ey, ex, err in cmdout:gmatch("[^\n]*:([0-9]+):([0-9]+): error: ([^\n]*)") do
      ey = tonumber(ey)
      ex = tonumber(ex)
      if not errors[ey] then errors[ey] = {} end
      errors[ey][ex] = err
   end
   return true
end

function on_key(code)
   return tab_complete.on_key(code)
end
