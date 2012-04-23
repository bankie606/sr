require "sr"

module Sr
  module Collector
    def self.reducers
      @reducers ||= Hash.new
    end

    def self.add_reducer(job_id, red)
      @reducers ||= Hash.new
      @reducers[job_id] = red
    end

    def self.remove_reducer(job_id)
      @reducers ||= Hash.new
      # return whether or not the job was successfully killed
      if @reducers.remove(job_id).nil?
        return false
      else
        return true
      end
    end

    class Reducer
      attr_accessor :workers
      attr_accessor :combine_block
      attr_accessor :n, :val

      def initialize(job_id, job_inst)
        @job_inst = job_inst
        @workers = Array.new
        Collector::add_reducer(job_id, self)
      end

      def add_worker(worker)
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
      def merge_results_from_worker(results)
        results.each do |r|
          new_props = @job_inst.collector_combine_block(r, @n, @val)
          @n = new_props[:n]
          @val = new_props[:val]
        end
      end
    end
  end
end

