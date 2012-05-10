#!/usr/bin/env ruby

$:.unshift "lib"
require "sr/util"
require "json"

# get gold results
gold = {}
File.open(File.join(File.dirname(__FILE__), "gold.json")) do |f|
  goldj = JSON.parse(f.read)
  goldj.each_pair do |k,v|
    gold[k.to_i] = v
  end
end

# get stopwords
require File.expand_path(File.join(File.dirname(__FILE__), "stopwords"))

# remove the stopwords
Stopwords.stopwords.each do |stopword|
  gold.delete(stopword)
end

def getTopK(hash, k)
  keys = hash.keys.sort.reverse[0, k]
  n = 0
  words = Hash.new(0)
  keys.each do |freq|
    hash[freq].each do |w|
      words[w] = freq
      n += 1
      puts "#{freq} & #{w}"
      break if n >= k
    end
    break if n >= k
  end
  words
end

getTopK(gold, 10)

[5,10].each do |exp|
  puts ""
  (1...2).each do |run|
    trial = {}
    File.open(File.join(File.dirname(__FILE__), "datadumps", "experiment-#{exp}-run-#{run}.json")) do |f|
      json = JSON.parse(f.read)
      json.each_pair do |k,v|
        trial[k.to_i] = v
      end
    end
    getTopK(trial, 10)
  end
end

