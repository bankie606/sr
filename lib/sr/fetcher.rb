require "sr"

module Sr
  module Fetcher
    def self.spouts
      @spouts ||= Hash.new
      @spouts
    end

    def self.add_sprout(job_id, sprout)
      @sprouts ||= Hash.new
      @sprouts[job_id] = sprout
    end

    def self.remove_spout(job_id)
      @sprouts ||= Hash.new
      # return whether or not the job was successfully killed
      if @sprouts.remove(job_id).nil?
        return false
      else
        return true
      end
    end


    class Spout
      attr_accessor :fetch_block, :seq_number
      attr_accessor :job_inst

      # spout takes a block. The block can have arity zero or one
      # If the block has arity one, it is passed the sequence number
      # of the number of fetches
      def initialize(job_id, job_inst)
        @job_inst = job_inst
        @seq_number = 0
        # keep track of ourselves
        Fetcher::add_sprout(job_id, self)
      end

      def fetch
        result = @job_inst.fetcher_fetch_block(@seq_number)
        @seq_number += 1
        result
      end
    end
  end
end

