        ---------------
  --==[[  Vannilla-FS  ]]==--
  --==[[  © 2024 monk  ]]==--
        ---------------
--[[
    Create tokens for neural network from string input
    Token format:
      {"monk", inputs = {0.109,0.111,0.11,0.107}, targets = {0,1}} -- not curse
      {"fuck", inputs = {0.102,0.117,0.099,0.107}, targets = {1,0}} -- curse
    Padded with 0.001 if string length is shorter than the longest
  ]]--

function string_to_ascii(s, n)
  local ascii_values = {}
  for i = 1, #s do
    local c = s:sub(i, i)
    ascii_values[#ascii_values+1] = string.byte(c)/1000
  end
  while #ascii_values < n do
      ascii_values[#ascii_values+1] = 0.001
  end
  return ascii_values
end

function generate_tokens()
  -- todo: user input
  local curses = dofile("./data/100_bad.lua")
  local words = dofile("./data/100_good.lua")
  local nodes = 0

  for n = 1,#curses do
    nodes = math.max(nodes, #curses[n])
  end

  for n = 1, #words do
    nodes = math.max(nodes, #words[n])
  end

  local tokens = {}
  for n = 1, #curses do
    if curses[n]:gmatch("^[a-zA-Z]+$") then  -- haven't tested with symbols/numbers
      tokens[#tokens+1] = {
        curses[n],
        inputs = string_to_ascii(curses[n], nodes),
        targets = {1,0}
      }
    end
  end

  for n = 1, #words do
    if words[n]:gmatch("^[a-zA-Z]+$") then
      tokens[#tokens+1] = {
        words[n],
        inputs = string_to_ascii(words[n], nodes),
        targets = {0,1}
      }
    end
  end
  return tokens, nodes
end

return generate_tokens()



------------------------------------------------------------------------------------
-- MIT License                                                                    --
--                                                                                --
-- Copyright © 2024 monk                                                          --
--                                                                                --
-- Permission is hereby granted, free of charge, to any person obtaining a copy   --
-- of this software and associated documentation files (the "Software"), to deal  --
-- in the Software without restriction, including without limitation the rights   --
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      --
-- copies of the Software, and to permit persons to whom the Software is          --
-- furnished to do so, subject to the following conditions:                       --
--                                                                                --
-- The above copyright notice and this permission notice shall be included in all --
-- copies or substantial portions of the Software.                                --
--                                                                                --
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     --
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       --
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    --
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         --
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  --
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  --
-- SOFTWARE.                                                                      --
------------------------------------------------------------------------------------
