require "sr"

module Sr
  module Fetcher
    def self.spouts
      @spouts ||= Hash.new
      @spouts
    end

    def self.add_spout(job_id, spout)
      @spouts ||= Hash.new
      @spouts[job_id] = spout
    end

    def self.remove_spout(job_id)
      @spouts ||= Hash.new
      # return whether or not the job was successfully killed
      if @spouts.remove(job_id).nil?
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
        @job_id = job_id
        @seq_number = 0
        # keep track of ourselves
        Fetcher::add_spout(job_id, self)
      end

      def fetch
        result = @job_inst.fetcher_fetch_block(@seq_number)
        if @seq_number % 100 == 0
          Sr.log.info("fetched #{@seq_number} records for jobid = #{@job_id}")
        end
        @seq_number += 1
        result
      end
    end
  end
end

