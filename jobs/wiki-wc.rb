require "sr/jobfile"

class WikipediaWordCount < Sr::Job::Jobfile
  attr_accessor :num_revs, :seq
  # collector
  attr_accessor :results


  def initialize
    @num_collectors = @num_fetchers = @num_workers = 1
    @num_revs = Sr::Util.send_message("localhost:7777", "num_revs", {})[:num_revs].to_i
    @seq = 0
    @results = Hash.new(0)
  end

  def collector_combine_block(results, n, val)
    results.each_pair do |word, count|
      val[word] = val[word] + count
    end
    { :val => val, :n => n + 1 }
  end

  def fetcher_fetch_block(*args)
    res = Sr::Util.send_message("localhost:7777", "next_rev/#{seq}", {})
    @seq += 1
    res
  end

  def worker_init_block(obj)
    obj.add_compute_method(1.0) do |datum|
      result = Hash.new(0)
      datum.split(/\s/).each do |word|
        word = word.gsub(/[\.,!\?]/, "")
        result[word] = result[word] + 1
      end
      result
    end
  end
end

WikipediaWordCount

