require "sr"

module Sr
  module Job
    # subclass Jobfile to define jobs for the sr cluster
    # All methods must be overridden and all instance vars set.
    # These provide the necessary configuration for the master
    # to start the job
    class Jobfile
      attr_accessor :num_collectors, :num_fetchers, :num_workers
      # used for killing tasks
      attr_accessor :kill_at_worker, :kill_at_master
      attr_accessor :kill_frequency

      def initialize
        @num_collectors = @num_fetchers = @num_workers = nil
        @kill_at_worker = true
        @kill_at_master = false
        @kill_frequency = nil
      end

      def collector_combine_block(results, n, val)
        raise NotImplementedError
      end

     def fetcher_fetch_block(*args)
        raise NotImplementedError
      end

      def worker_init_block(obj)
        raise NotImplementedError
      end
    end
  end
end

