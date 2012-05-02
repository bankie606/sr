#!/usr/bin/env ruby

$:.unshift "lib"
require "sr/util"
require "json"

# get gold results
gold = nil
File.open(File.join(File.dirname(__FILE__), "gold.json")) do |f|
  goldj = JSON.parse(f.read)
  gold = {}
  goldj.each_pair do |k,v|
    gold[k.to_i] = v
  end
end

port = 6668
#port = 5557

# get silver results
result = Sr::Util.send_message("localhost:#{port}", "result", {})[:result]

# get stopwords
require File.expand_path(File.join(File.dirname(__FILE__), "stopwords"))

# remove the stopwords
Stopwords.stopwords.each do |stopword|
  result.delete(stopword)
end


h = result
h_inv = Hash.new { Array.new }
h.each_pair { |k,v| h_inv[v.to_i] = h_inv[v] << k }

expnum = 4
runnum = 3
if File.exists?(File.join(File.dirname(__FILE__), "datadumps",
                    "experiment-#{expnum}-run-#{runnum}.json"))
  puts "file already exists"
  abort
end

File.open(File.join(File.dirname(__FILE__), "datadumps",
                    "experiment-#{expnum}-run-#{runnum}.json"), "w") do |f|
  f.puts h_inv.to_json
end

