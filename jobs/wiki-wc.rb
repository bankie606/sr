require "sr/jobfile"

require "base64"
require "zlib"

class WikipediaWordCount < Sr::Job::Jobfile
  attr_accessor :num_revs, :seq
  # collector
  attr_accessor :results


  def initialize
    @num_collectors = @num_fetchers = 1
    @num_workers = 2
    @num_revs = Sr::Util.send_message("air.local:7777", "num_revs", {})[:num_revs].to_i
    @seq = 0
    @results = Hash.new(0)
  end

  def collector_combine_block(results, n, val)
    val ||= Hash.new(0)
    n ||= 0
    results.each_pair do |word, count|
      val[word] = val[word] + count
    end
    { :val => val, :n => n + 1 }
  end

  def fetcher_fetch_block(*args)
    return nil if @seq >= @num_revs
    res = Sr::Util.send_message("air.local:7777", "next_rev/#{@seq}", {})
    @seq += 1
    res["#{@seq-1}"]
  end

  def worker_init_block(obj)
    obj.add_compute_method(1.0) do |datum|
      result = Hash.new(0)
      datum = Zlib::Inflate.inflate(datum[:fulltext])
      datum = Base64::decode64(datum)
      datum.split(/\s/).each do |word|
        next if !(word =~ /^[\u0000-\u007F]+$/)
        word = word.downcase
        next if !(word =~ /^[a-z0-9\-]+$/)
        word = word.gsub(/[\.,!\?]$/, "").downcase
       result[word] = result[word] + 1
      end
      result
    end
  end
end

WikipediaWordCount

