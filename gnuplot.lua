        ---------------
  --==[[  Vannilla-FS  ]]==--
  --==[[  © 2024 monk  ]]==--
        ---------------
--[[
    Plots data points to a line chart from total and average losses
    Requires: gnuplot, for graphic chat
    Replace "feh" with your preferred image viewer
  ]]
local image_viewer = "feh"

function record_datapoints(plot_data, epochs, learn_rate, batch_size, hidden_layers, output_layer)
  local final_loss_total = plot_data[#plot_data][1]
  local final_loss_average = plot_data[#plot_data][2]
  local epochs, learn_rate, batch_size, gradient_decay, epsilon, hidden_layers, output_layer = 
        epochs, learn_rate, batch_size, gradient_decay, epsilon, hidden_layers, output_layer

  local trial_id = "vnf_"..os.date("%F_%H:%M:%S").."_"
      ..string.format("%.2f", final_loss_total).."-"
      ..string.format("%.2f", final_loss_average)

  local gnuplot_command = [[
      gnuplot -p -e "set terminal pngcairo background '#00232323' size 1800, 600;\
        set output './training/]] .. trial_id .. [[.png';\
        set title 'Title';\
        set xlabel 'Epoch';\
        set autoscale;\
        plot 
        '< cat ./training/]] .. trial_id .. [[.txt' using 1 pt 1 lc 1 with lines title 'Total Loss',\
        '< cat ./training/]] .. trial_id .. [[.txt' using 2 pt 2 lc 2 with points title 'Mean Loss'"
  ]]

  local file = io.open("./training/"..trial_id..".txt", "w+")

  if file then
    local header = "epochs = "..epochs
              .. ", learn_rate = "..learn_rate
              .. ", batch_size = "..batch_size
              .. ", hidden_layers = "..hidden_layers
              .. ", output_layer = "..output_layer.. "\n"

    file:write(header)
      for i = 1, #plot_data do
        file:write(plot_data[i][1].."\t"..plot_data[i][2].."\n")
      end
    end

    file:close()
    os.execute(gnuplot_command)
    os.execute(image_viewer.." ./training/"..trial_id..".png")
  return
end

return record_datapoints



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
