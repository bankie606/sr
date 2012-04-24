require "sr"

require "timeout"

module Sr
  module Worker
    def self.execers
      @execers ||= Hash.new
    end

    def self.add_execer(job_id, exc)
      @execers ||= Hash.new
      @execers[job_id] = exc
    end

    def self.remove_execer(job_id)
      @execers ||= Hash.new
      # return whether or not the job was successfully killed
      if @execers.remove(job_id).nil?
        return false
      else
        return true
      end
    end

    class Execer
      # A hash from an accuracy metric to a proc
      # higher accuracy metric => higher fidelity computation
      attr_accessor :compute_methods
      # these attributes are used to determine how accurate this
      # worker has been so far
      attr_accessor :num_datum, :num_killed
      attr_accessor :weighted_accuracy_score, :target_accuracy_score
      attr_accessor :timeout, :kill_frequency
      # worker metadata about how it did the job
      attr_accessor :compute_method_counts

      # results so far
      attr_accessor :results

      DEFAULT_TIMEOUT = 1.0
      DEFAULT_KILL_FREQUENCY = 0.1
      DEFAULT_TARGET_ACCURACY = 0.8

      attr_accessor :job_inst

      def initialize(job_id, job_inst)
        @compute_methods = Hash.new
        @num_datum = @num_killed = 0
        @weighted_accuracy_score = 0.0
        @target_accuracy_score = DEFAULT_TARGET_ACCURACY
        @timeout = DEFAULT_TIMEOUT
        @kill_frequency = DEFAULT_KILL_FREQUENCY
        @results = Array.new
        @compute_method_counts = Hash.new(0)

        # run init block
        @job_inst = job_inst
        @job_id = job_id
        job_inst.worker_init_block(self)

        Worker::add_execer(job_id, self)
      end

      def add_compute_method(accuracy, &block)
        if block.arity < 1 || block.arity > 2
          raise ArgumentError "block must have arity of 1 or 2"
        end
        @compute_methods[accuracy] = block
      end

      # this function is called on every datum
      # This function chooses the compute method to use and tries to
      # execute it within @timeout time.
      # Updates accuracy metrics.
      def compute(datum)
        acc = choose_accuracy
        Sr.log.info("job(#{@job_id}) - worker using acc = #{acc}")
        block = @compute_methods[acc]
        result = nil
        begin
          # preemptively kill some tasks
          raise Timeout::Error if rand() < @kill_frequency
          # try to do it
          result = Timeout::timeout(@timeout) do
            if block.arity == 1
              block.call datum
            else
              block.call datum @num_datum
            end
          end
          @weighted_accuracy_score = (@weighted_accuracy_score *
                                      @num_datum + acc) / (@num_datum + 1.0)
          @compute_method_counts[acc] += 1
        rescue Timeout::Error => e
          # we killed the task because it was taking too long
          @num_killed += 1
          @weighted_accuracy_score = (@weighted_accuracy_score *
                                      @num_datum) / (@num_datum + 1.0)
          Sr.log.info("job(#{@job_id}) - killed task")
        end
        @num_datum += 1
        @results << result
      end

      # choose the lowest accuracy we can that satisfies the target
      # accuracy requirement or the best compute method if we can't
      def choose_accuracy
        @compute_methods.keys.sort.each do |acc|
          projected_accuracy_score = (@weighted_accuracy_score *
                                      @num_datum + acc) / (@num_datum + 1.0)
          return acc if projected_accuracy_score >= @target_accuracy_score
        end
        @compute_methods.keys.max
      end

      # get a workers results so far and clear the results array
      # workers don't remember their results forever
      def get_results
        res = Array.new(@results)
        @results.clear
        res
      end

      # returns metadata about a job
      # metadata persists forever
      def get_metadata
        { :compute_counts => @compute_method_counts, :kill_count => @num_killed }
      end
    end
  end
end
