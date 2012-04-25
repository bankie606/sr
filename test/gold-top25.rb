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

h = result
h_inv = Hash.new { Array.new }
h.each_pair { |k,v| h_inv[v] = h_inv[v] << k }
freqs = h_inv.keys.sort.reverse[0, 25]
freqs.each_index do |rank|
  freq = freqs[rank]
  puts "#{rank+1}. #{freq} : #{h_inv[freq].sort}"
end

=begin
with num_revs = 500
=====================
1. 224592 : ["the"]
2. 132722 : ["of"]
3. 96257 : ["and"]
4. 79770 : ["in"]
5. 67318 : ["to"]
6. 60364 : ["a"]
7. 30709 : ["was"]
8. 24830 : ["as"]
9. 24286 : ["for"]
10. 23730 : ["on"]
11. 23075 : ["by"]
12. 22285 : ["that"]
13. 22155 : ["with"]
14. 20810 : ["is"]
15. 16990 : ["his"]
16. 16670 : ["from"]
17. 15630 : ["at"]
18. 13446 : ["he"]
19. 11701 : ["it"]
20. 11233 : ["were"]
21. 11191 : ["an"]
22. 9803 : ["had"]
23. 9277 : ["are"]
24. 9216 : ["which"]
25. 8817 : ["be"]
=end
