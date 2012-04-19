require "sr"

module Sr
  module Job
    # subclass Jobfile to define jobs for the sr cluster
    # All methods must be overridden and all instance vars set.
    # These provide the necessary configuration for the master
    # to start the job
    class Jobfile
      attr_accessor :num_collectors, :num_fetchers, :num_workers

      def initialize
        @num_collectors = @num_fetchers = @num_workers = nil
      end

      def collector_combine_block(results, n, val)
        raise NotImplementedError
      end

      def fetcher_fetch_block
        raise NotImplementedError
      end

      def worker_init_block
        raise NotImplementedError
      end
    end
  end
end

