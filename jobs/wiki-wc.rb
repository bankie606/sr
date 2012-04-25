require "sr/jobfile"

require "base64"
require "zlib"

class WikipediaWordCount < Sr::Job::Jobfile
  attr_accessor :num_revs, :seq
  # collector
  attr_accessor :results


  def initialize
    @ip = "18.111.111.13"
    @num_collectors = @num_fetchers = 1
    @num_workers = 4
    @num_revs = Sr::Util.send_message("#{@ip}:7777", "num_revs", {})[:num_revs].to_i
    # @num_revs = 500
    @seq = 0
    @results = Hash.new(0)
  end

  def collector_combine_block(results, n, val)
    val ||= Hash.new(0)
    n ||= 0
    results ||= Hash.new(0)
    results.each_pair do |word, count|
      val[word] = val[word] + count
    end
    { :val => val, :n => n + 1 }
  end

  def fetcher_fetch_block(*args)
    return nil if @seq >= @num_revs
    res = Sr::Util.send_message("#{@ip}:7777", "next_rev/#{@seq}", {})
    @seq += 1
    res["#{@seq-1}"]
  end

  def worker_init_block(obj)
    # set tuning params

    # obj.target_accuracy_score = 0.4
    # obj.kill_frequency = 0.1

    # do the word count for real
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
      @cached_result = result
    end
    # do the word count for about half of the article
    obj.add_compute_method(0.25) do |datum|
      result = Hash.new(0)
      datum = Zlib::Inflate.inflate(datum[:fulltext])
      datum = Base64::decode64(datum)
      # do the word count on a substring
      start = datum.index(/\s/, rand(datum.length / 2))
      stop = [datum.length - 1, start + datum.length / 2].min
      len = stop - start
      datum[start, len].split(/\s/).each do |word|
        next if !(word =~ /^[\u0000-\u007F]+$/)
        word = word.downcase
        next if !(word =~ /^[a-z0-9\-]+$/)
        word = word.gsub(/[\.,!\?]$/, "").downcase
       result[word] = result[word] + 1
      end
      @cached_result = result
    end
    # do the word count for about a quarter of the article
    obj.add_compute_method(0.25) do |datum|
      result = Hash.new(0)
      datum = Zlib::Inflate.inflate(datum[:fulltext])
      datum = Base64::decode64(datum)
      # do the word count on a substring
      start = datum.index(/\s/, rand(datum.length / 2))
      stop = datum.index(/\s/, start + rand(datum.length / 2))
      stop = stop.nil? ? datum.length - 1 : stop
      len = stop - start
      datum[start, len].split(/\s/).each do |word|
        next if !(word =~ /^[\u0000-\u007F]+$/)
        word = word.downcase
        next if !(word =~ /^[a-z0-9\-]+$/)
        word = word.gsub(/[\.,!\?]$/, "").downcase
       result[word] = result[word] + 1
      end
      @cached_result = result
    end
    # return a hash for a previous article
    obj.add_compute_method(0.1) do |datum|
      @cached_result || Hash.new(0)
    end
  end
end

WikipediaWordCount

