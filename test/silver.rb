#!/usr/bin/env ruby

$:.unshift "lib"
require "sr/util"

result = Sr::Util.send_message("localhost:6668", "result", {})[:result]


h = result
h_inv = Hash.new { Array.new }
h.each_pair { |k,v| h_inv[v.to_i] = h_inv[v] << k }
puts "freq: #{h_inv.keys.max} | count: #{h_inv[h_inv.keys.max].length}"
puts h_inv[h_inv.keys.max].sort.to_s

# ▶ test/silver.rb
# freq: 1345760 | count: 1
# ["the"]
