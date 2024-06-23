        ---------------
  --==[[  Vannilla-FS  ]]==--
  --==[[  © 2024 monk  ]]==--
        ---------------
local use_gnuplot = true -- see gnuplot.lua

dofile("token.lua")
local token_data, input_nodes = generate_tokens()

local function shuffle(t)
  for i = #t, 2, -1 do
    local r = math.random(i)
    t[i], t[r] = t[r], t[i]
  end

  local inputs, targets = {}, {}
  for _, entry in ipairs(t) do
    table.insert(inputs, entry.inputs)
    table.insert(targets, entry.targets)
  end

  return inputs, targets
end

local function generate(layers)
  local brain = {
    network = {}, 
    queue_start = {}, 
    queue_end = {}
  }
  
  local last_layer = {}
  local current_layer = {}
  
  for layer_index, node_amount in ipairs(layers) do 
    for i = 1, node_amount do
      local node_index = #brain.network + 1
      local node = {
        index = node_index, 
        input_nodes = {}, 
        output_nodes = {}, 
        output = 0, 
        weights = {}, 
        bias = math.random() * 2 - 1
      }
      
      if layer_index > 1 then
        for _, node_index2 in ipairs(last_layer) do
          local node2 = brain.network[node_index2]
          table.insert(node2.output_nodes, node_index)
          table.insert(node.input_nodes, node_index2)
          table.insert(node.weights, math.random() * 2 - 1)
        end
      end
      
      if layer_index == 1 then
        table.insert(brain.queue_start, node_index)
      elseif layer_index == #layers then 
        table.insert(brain.queue_end, node_index)
      end
      
      brain.network[node_index] = node
      table.insert(current_layer, node_index)
    end
    
    last_layer = current_layer
    current_layer = {}
  end
  
  return brain
end


local function forward_propagate(brain, input)
  for i, node_index in ipairs(brain.queue_start) do
    brain.network[node_index].output = input[i]
  end

  for _, node in ipairs(brain.network) do
    if #node.input_nodes > 0 then
      local sum = 0
      for i, input_node_index in ipairs(node.input_nodes) do
        local input_node = brain.network[input_node_index]
        sum = sum + input_node.output * node.weights[i]
      end
      sum = sum + node.bias
      node.output = 1 / (1 + math.exp(-sum))  -- sigmoid
    end
  end

  local outputs = {}
  for _, node_index in ipairs(brain.queue_end) do
    table.insert(outputs, brain.network[node_index].output)
  end

  return outputs
end

local function backpropagate(brain, inputs, targets, learning_rate)
  local outputs = forward_propagate(brain, inputs)

  local deltas = {}
  for i, node_index in ipairs(brain.queue_end) do
    local node = brain.network[node_index]
    local loss = targets[i] - node.output
    local delta = loss * node.output * (1 - node.output)
    deltas[node_index] = delta
  end

  for layer = #brain.network, 1, -1 do
    for _, node in ipairs(brain.network) do
      if deltas[node.index] then
        for i, input_node_index in ipairs(node.input_nodes) do
          local input_node = brain.network[input_node_index]
          local delta = deltas[node.index] * node.weights[i] * input_node.output * (1 - input_node.output)
          deltas[input_node_index] = (deltas[input_node_index] or 0) + delta
        end
      end
    end
  end

  for _, node in ipairs(brain.network) do
    if deltas[node.index] then
      for i, input_node_index in ipairs(node.input_nodes) do
        local input_node = brain.network[input_node_index]
        node.weights[i] = node.weights[i] + learning_rate * deltas[node.index] * input_node.output
      end
      node.bias = node.bias + learning_rate * deltas[node.index]
    end
  end
end


local function train(brain, token_data, epochs, learning_rate, batch_size)
  local plot_data = {}
  
  for epoch = 1, epochs do
    local total_loss = 0
    local inputs, targets = shuffle(token_data)
    
    for i = 1, #inputs, batch_size do
      local batch_inputs, batch_targets = {}, {}
      for j = i, math.min(i + batch_size - 1, #inputs) do
        table.insert(batch_inputs, inputs[j])
        table.insert(batch_targets, targets[j])
      end
      
      for k, input in ipairs(batch_inputs) do
        backpropagate(brain, input, batch_targets[k], learning_rate)
        local output = forward_propagate(brain, input)
        local loss = 0
        for l = 1, #output do
          loss = loss + (batch_targets[k][l] - output[l]) ^ 2
        end
        total_loss = total_loss + loss
      end
    end
    
    local average_loss = total_loss / #token_data
    
    if epoch % 10 == 0 then
      print(string.format("Epoch: %d, Batch Loss: %.4f, Mean Loss: %.6f", epoch, total_loss, average_loss))
      plot_data[#plot_data+1] = {total_loss, average_loss}
    end
  end
  
  return plot_data
end

local batch_size = 16
local hidden_layers, output_layer = 6, 2
local epochs, learn_rate = 1000, 0.0085
local brain = generate({input_nodes, hidden_layers, output_layer})


if use_gnuplot then
  dofile("gnuplot.lua")
  record_datapoints(train(brain, token_data, epochs, learn_rate, batch_size),
      epochs, learn_rate, batch_size, hidden_layers, output_layer)
else
  train(brain, token_data, epochs, learn_rate)
end





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
