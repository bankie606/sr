require "sr"

module Sr
  module Master
    class Jobtracker
      attr_accessor :jobs
      attr_accessor :job_fetcher_map, :job_worker_map, :job_collector_map
      attr_accessor :nodes # list of nodes in the cluster
      attr_accessor :task_counts # used for assigning tasks in a job

      def initialize
        @jobs = Array.new
        # membership maps
        @job_fetcher_map = Hash.new { |h,k| Array.new }
        @job_worker_map = Hash.new { |h,k| Array.new }
        @job_collector_map = Hash.new { |h,k| Array.new }
        # scheudling tools
        @nodes = Array.new
        @task_counts = Hash.new { |h,k| Array.new }
      end

      def add_node node
        @nodes.push node
        @task_counts[0] = @task_counts[0] << node
      end

      def add_job_and_start job
        @jobs.push job

        job.num_fetchers.times do |i|
          node = get_node_for_task
          @job_fetcher_map[job] = @job_fetcher_map[job] << node
        end
        job.num_workers.times do |i|
          node = get_node_for_task
          @job_worker_map[job] = @job_worker_map[job] << node
        end
        job.num_collectors.times do |i|
          node = get_node_for_task
          @job_colector_map[job] = @job_colelctor_map[job] << node
        end

      end

      # chose one of the least worked nodes to perform a task
      # This is essentially weighted round robin scheduling
      def get_node_for_task
        # get the least burdened nodes
        least_worked = @task_counts[@task_counts.keys.min]
        # choose one of them
        node = least_worked.shift
        # restore the list
        @task_counts[@task_counts.keys.min] = least_worked
        # up the chosen node's burden count
        @task_counts[@task_counts.keys.min + 1] =
          @task_counts[@task_counts.keys.min + 1] << node

        node
      end
    end

    class Job
      attr_accessor :num_fetchers, :num_workers, :num_collectors
      attr_accessor :id
      @@jobid = 0

      def initialize(nf, nw, nc)
        @num_fetchers = nf
        @num_workers = nw
        @num_collectors = nc

        # set id
        @id = @@jobid
        @@jobid += 1
      end
    end
  end
end

