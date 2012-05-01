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

# get silver results
result = Sr::Util.send_message("localhost:6668", "result", {})[:result]

# get stopwords
require File.expand_path(File.join(File.dirname(__FILE__), "stopwords"))

# remove the stopwords
Stopwords.stopwords.each do |stopword|
  result.delete(stopword)
end


h = result
h_inv = Hash.new { Array.new }
h.each_pair { |k,v| h_inv[v.to_i] = h_inv[v] << k }

# top 25 silver
top25s = h_inv.keys.sort.reverse[0, 25]
# top 50 silver
top50s = h_inv.keys.sort.reverse[0, 50]
# top 100 silver
top100s = h_inv.keys.sort.reverse[0, 100]

# bottom 50 silver
bot50s = h_inv.keys.sort[0, 1000]
# bottom 100 silver
bot100s = h_inv.keys.sort[0, 5000]
# top 250 silver
bot250s = h_inv.keys.sort[0, 10000]

# top 25 gold
top25g = gold.keys.sort.reverse[0, 25]
# top 50 gold
top50g = gold.keys.sort.reverse[0, 50]
# top 100 gold
top100g = gold.keys.sort.reverse[0, 100]

# bottom 50 gold
bot50g = gold.keys.sort[0, 1000]
# bottom 100 gold
bot100g = gold.keys.sort[0, 5000]
# top 250 gold
bot250g = gold.keys.sort[0, 10000]

def fmeasure(silver_keys, gold_keys, h_inv, gold, len)
  silver_words = Hash.new(0)
  silver_keys.each do |s|
    #silver_words << h_inv[s]
    h_inv[s].each do |w|
      silver_words[w] = 1
    end
    break if silver_words.keys.length >= len
  end
  gold_words = Hash.new(0)
  gold_keys.each do |g|
    #gold_words << gold[g]
    gold[g].each do |w|
      gold_words[w] = 1
    end
    break if gold_words.keys.length >= len
  end
  n = 0
  silver_words.each_pair do |sword,i|
    if gold_words[sword] == 0
      n += 1
    end
  end
  n
end

puts "Top 25:    #{fmeasure(top25s,  top25g, h_inv, gold, 25)}"
puts "Top 50:    #{fmeasure(top50s,  top50g, h_inv, gold, 50)}"
puts "Top 100:   #{fmeasure(top100s, top100g, h_inv, gold, 100)}"
puts "Bot 1000:  #{fmeasure(bot50s,  bot50g, h_inv, gold, 1000)}"
puts "Bot 5000:  #{fmeasure(bot100s, bot100g, h_inv, gold, 5000)}"
puts "Top 10000: #{fmeasure(bot250s, bot250g, h_inv, gold, 10000)}"

