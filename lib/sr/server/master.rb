require "sr"

require "json"
require "sinatra/base"
require "uri"

module Sr
  module Master

    class Server < Sinatra::Base
      get "/#{Sr::MessageTypes::CREATE_JOB}" do
        # eval the jobfile and instantiate it
        jobfile_src = URI::decode(params[:jobfile])
        job_class = eval(jobfile_src)
        job_inst = job_class.new

        # create the job
        Sr::Master::Job.new(job_inst.num_fetchers, job_inst.num_collectors,
                            job_inst.num_workers,
                            proc { job_inst.fetcher_fetch_block },
                            proc { job_inst.worker_init_block },
                            proc { job_inst.collector_combine_block })
        { :success => true }.to_json
      end

      get "/#{Sr::MessageTypes::COLLECTOR_CREATED}" do
        # create partial node
        Master::jobtracker.add_partial_node(params[:uuid], params[:ipaddr],
                                            :collector_port=, params[:port])
        { :success => true }.to_json
      end

      get "/#{Sr::MessageTypes::FETCHER_CREATED}" do
        # create partial node
        Master::jobtracker.add_partial_node(params[:uuid], params[:ipaddr],
                                            :fetcher_port=, params[:port])
        { :success => true }.to_json
      end

      get "/#{Sr::MessageTypes::WORKER_CREATED}" do
        # create partial node
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

