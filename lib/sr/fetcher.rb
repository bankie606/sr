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

    class Spout
      attr_accessor :fetch_block, :seq_number

      # spout takes a block. The block can have arity zero or one
      # If the block has arity one, it is passed the sequence number
      # of the number of fetches
      def initialize(job_id, &block)
        @fetch_block = block
        @seq_number = 0
        # keep track of ourselves
        Fetcher::add_sprout(job_id, self)
      end

      def fetch
        result =
          if @fetch_block.arity == 0
            @fetch_block.call
          elsif @fetch_block.arity == 1
            @fetch_block.call @seq_number
          end
        @seq_number += 1
        result
      end
    end
  end
end

