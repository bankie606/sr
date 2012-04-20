require "sr"

module Sr
  module Master
    def self.jobtracker
      @jobtracker
    end

    def self.jobtracker=(jobtracker)
      @jobtracker = jobtracker
    end

    # exceptions
    class FailedToCreateCollectorException < Exception; end;
    class FailedToCreateFetcherException < Exception; end;
    class FailedToCreateWorkerException < Exception; end;

    class Jobtracker
      attr_accessor :jobs
      attr_accessor :job_fetcher_map, :job_worker_map, :job_collector_map
      attr_accessor :nodes # list of nodes in the cluster
      attr_accessor :partial_nodes # list of partially initialized nodes
      attr_accessor :task_counts # used for assigning tasks in a job

      def initialize
        @jobs = Array.new
        # membership maps
        @job_fetcher_map = Hash.new { |h,k| Array.new }
        @job_worker_map = Hash.new { |h,k| Array.new }
        @job_collector_map = Hash.new { |h,k| Array.new }
        # scheudling tools
        @nodes = Array.new
        @partial_nodes = Hash.new
        @task_counts = Hash.new { |h,k| Array.new }

        Master::jobtracker = self
      end

      def add_partial_node(uuid, ipaddr, type, port)
        partial_node = @partial_nodes[uuid] || Node.new
        partial_node.ipaddr = ipaddr
        partial_node.send(type, port)
        if partial_node.complete?
          add_node(node)
          @partial_nodes.delete(uuid)
        else
          @partial_nodes[uuid] = partial_node
        end
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
          resp = Sr::Util.send_message("#{node.ipaddr}:#{node.fetcher_port}",
                                       Sr::MessageTypes::NEW_JOB,
                                       { :job_id => job.id,
                                         :jobfile => job.jobfile })
          raise FailedToCreateFetcherException if !resp[:success]
        end
        job.num_workers.times do |i|
          node = get_node_for_task
          @job_worker_map[job] = @job_worker_map[job] << node
          resp = Sr::Util.send_message("#{node.ipaddr}:#{node.worker_port}",
                                       Sr::MessageTypes::NEW_JOB,
                                       { :job_id => job.id,
                                         :jobfile => job.jobfile })
          raise FailedToCreateWorkerException if !resp[:success]
        end
        job.num_collectors.times do |i|
          node = get_node_for_task
          @job_colector_map[job] = @job_colelctor_map[job] << node
          resp = Sr::Util.send_message("#{node.ipaddr}:#{node.collector_port}",
                                       Sr::MessageTypes::NEW_JOB,
                                       { :job_id => job.id,
                                         :jobfile => job.jobfile })
          raise FailedToCreateCollectorException if !resp[:success]
        end

      end

      # chose one of the least worked nodes to perform a task
      # This is essentially weighted round robin scheduling
      def get_node_for_task
        # get the least burdened nodes
        least_burdened_job_count = @task_counts.keys.min
        least_worked = @task_counts[least_burdened_job_count]
        # choose one of them
        node = least_worked.shift

        # restore the list
        if least_worked.length > 0
          @task_counts[least_burdened_job_count] = least_worked
        else # or delete it if there are no nodes with this count left
          @task_counts.delete(least_burdened_job_count)
        end

        # increment the chosen node's burden count
        @task_counts[least_burdened_job_count + 1] =
          @task_counts[least_burdened_job_count + 1] << node

        node
      end
    end

    class Job
      attr_accessor :num_fetchers, :num_workers, :num_collectors
      attr_accessor :id
      attr_accessor :jobfile
      @@jobid = 0

      # initialize a job with a the number of each node type
      # and a stringified proc for each node type
      def initialize(nf, nw, nc, jobfile)
        @num_fetchers = nf
        @num_workers = nw
        @num_collectors = nc

        @jobfile = jobfile

        # set id
        @id = @@jobid
        @@jobid += 1
      end
    end
  end
end

