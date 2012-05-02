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
      words[w] = 1
      n += 1
      break if n >= k
    end
    break if n >= k
  end
  words
end

def precision(gold, silver)
  n = 0
  gold.keys.each do |g|
    n += silver[g]
  end
  n
end

def recallForBottomK(gold, silver, k)
  keys = gold.keys.sort[0, k]
  silver_inv = {}
  silver.each_pair do |k,v|
    v.each do |w|
      silver_inv[w] = k
    end
  end
  n = 0
  words = Hash.new(0)
  keys.each do |freq|
    gold[freq].each do |w|
      words[w] = 1
      n += 1
      break if n >= k
    end
    break if n >= k
  end
  n = 0
  words.keys.each do |g|
    n += 1 if silver_inv[g]
  end
  n
end

puts "%-5s%-10s%-10s%-10s%-10s%-10s%-10s%-10s%-10s" % ["exp", "t1 pre", "t1 recall",
                                               "t2 pre", "t2 recall", "t3 pre",
                                               "t4 recall", "t4 pre", "t4 recall"]
(1..10).each do |exp|
  trial_results = ["#{exp}"]
  (1..4).each do |run|
    trial = {}
    File.open(File.join(File.dirname(__FILE__), "datadumps", "experiment-#{exp}-run-#{run}.json")) do |f|
      json = JSON.parse(f.read)
      json.each_pair do |k,v|
        trial[k.to_i] = v
      end
    end
    top100s = getTopK(trial, 100)
    top100g = getTopK(gold, 100)
    trial_results << precision(top100g, top100s)
    trial_results << recallForBottomK(gold, trial, 10000)
  end
  puts "%-5s%-10s%-10s%-10s%-10s%-10s%-10s%-10s%-10s" % trial_results
end

puts ""
puts "%-25s%5d" % ["Precision (top k)", 100]
puts "%-25s%5d" % ["Recall (bot k)", 10000]
