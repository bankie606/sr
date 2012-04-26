#!/usr/bin/env ruby

$:.unshift "lib"
require "sr/util"

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
freqs = h_inv.keys.sort.reverse[0, 25]
freqs.each_index do |rank|
  freq = freqs[rank]
  puts "#{rank+1}. #{freq} : #{h_inv[freq].sort}"
end

=begin

with num_revs = 500 && wiki-wc = 5c5bae6d891253fd57d1fe7bb8aa904fa9591c36
===================
▶ test/silver-top25.rb
1. 193520 : ["the"]
2. 113374 : ["of"]
3. 83554 : ["and"]
4. 69650 : ["in"]
5. 58798 : ["to"]
6. 52953 : ["a"]
7. 26924 : ["was"]
8. 21500 : ["as"]
9. 21247 : ["for"]
10. 20750 : ["on"]
11. 20065 : ["by"]
12. 19885 : ["that"]
13. 19409 : ["with"]
14. 17891 : ["is"]
15. 14911 : ["his"]
16. 14566 : ["from"]
17. 13618 : ["at"]
18. 11838 : ["he"]
19. 10215 : ["it"]
20. 9761 : ["an"]
21. 9710 : ["were"]
22. 8676 : ["had"]
23. 8045 : ["are"]
24. 8035 : ["which"]
25. 7912 : ["be"]
=end
