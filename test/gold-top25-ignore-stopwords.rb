#!/usr/bin/env ruby

$:.unshift "lib"
require "sr/util"
require "base64"
require "zlib"

@num_revs = Sr::Util.send_message("localhost:7777", "num_revs", {})[:num_revs].to_i
# @num_revs = 500
@seq = 0

result = Hash.new(0)

while @seq < @num_revs
  res = Sr::Util.send_message("localhost:7777", "next_rev/#{@seq}", {})
  @seq += 1
  datum = res["#{@seq-1}"]
  datum = Zlib::Inflate.inflate(datum[:fulltext])
  datum = Base64::decode64(datum)
  datum.split(/\s/).each do |word|
    next if !(word =~ /^[\u0000-\u007F]+$/)
    word = word.downcase
    next if !(word =~ /^[a-z0-9\-]+$/)
    word = word.gsub(/[\.,!\?]$/, "").downcase
    result[word] = result[word] + 1
  end
  puts @seq if @seq % 200 == 0
end

# get stopwords
require File.expand_path(File.join(File.dirname(__FILE__), "stopwords"))

# remove the stopwords
Stopwords.stopwords.each do |stopword|
  result.delete(stopword)
end

h = result
h_inv = Hash.new { Array.new }
h.each_pair { |k,v| h_inv[v] = h_inv[v] << k }
freqs = h_inv.keys.sort.reverse[0, 25]
freqs.each_index do |rank|
  freq = freqs[rank]
  puts "#{rank+1}. #{freq} : #{h_inv[freq].sort}"
end

