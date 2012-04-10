require "sr"

module Sr
  module Collector
    def self.reducers
      @reducers ||= Array.new
    end

    def self.add_reducer red
      @reducers ||= Array.new
      @reducers.push red
    end

    class Reducer
      attr_accessor :workers
      attr_accessor :combine_block
      attr_accessor :n, :val

      def initialize &combine_block
        @workers = Array.new
        if combine_block.arity != 3
          raise ArgumentError "combine_block must have an arity of 3:"+
            " block(results, n, val)"
        end
        Collector::add_reducer self
      end

      def add_worker worker
        @workers.push worker
      end

      # results should be a hash that has attributes
      # :n and :val
      #
      # This method calls @combine_block, which should
      # have an arity of 3. Its parameters are
      # results, @n, @val
      #
      # This method should return a hash with the
      # attributes :n and :val representing the new
      # state of these instance variables
      def merge_results_from_worker results
        new_props = @combine_block.call(results, @n, @val)
        @n = new_props[:n]
        @val = new_props[:val]
      end
    end
  end
end

