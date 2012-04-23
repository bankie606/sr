require "sr"

require "json"
require "sinatra/base"
require "uri"

module Sr
  module Master

    class Server < Sinatra::Base
      def self.get_or_post(path, opts={}, &block)
        get(path, opts, &block)
        post(path, opts, &block)
      end

      get_or_post "/#{Sr::MessageTypes::CREATE_JOB}" do
        # eval the jobfile and instantiate it
        job_inst = Sr::Util.eval_jobfile(params[:jobfile])

        # create the job
        job = Sr::Master::Job.new(job_inst.num_fetchers, job_inst.num_collectors,
                                  job_inst.num_workers,
                                  URI::decode(params[:jobfile]))
        Sr::Master.jobtracker.add_job_and_start(job)
        { :success => true }.to_json
      end

      get_or_post "/#{Sr::MessageTypes::COLLECTOR_CREATED}" do
        # create partial node
        Sr.log.debug(request.path)
        Master::jobtracker.add_partial_node(params[:uuid], params[:ipaddr],
                                            :collector_port=, params[:port])
        { :success => true }.to_json
      end

      get_or_post "/#{Sr::MessageTypes::FETCHER_CREATED}" do
        # create partial node
        Sr.log.debug(request.path)
        Master::jobtracker.add_partial_node(params[:uuid], params[:ipaddr],
                                            :fetcher_port=, params[:port])
        { :success => true }.to_json
      end

      get_or_post "/#{Sr::MessageTypes::WORKER_CREATED}" do
        # create partial node
        Sr.log.debug(request.path)
        Master::jobtracker.add_partial_node(params[:uuid], params[:ipaddr],
                                            :worker_port=, params[:port])
        { :success => true }.to_json
      end
    end

    def self.start_server
      Server.run! :port => Sr::node.master_port
    end
  end
end

