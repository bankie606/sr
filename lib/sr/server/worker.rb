require "sr"

require "json"
require "sinatra/base"

module Sr
  module Worker

    class Server < Sinatra::Base
      def self.get_or_post(path, opts={}, &block)
        get(path, opts, &block)
        post(path, opts, &block)
      end

      get_or_post "/#{Sr::MessageTypes::NEW_JOB}" do
        # eval the jobfile and instantiate it
        job_inst = Sr::Util.eval_jobfile(params[:jobfile])

        # create execer and add it to the pool of execers in this node
        # TODO: document what init block is expected to setup
        Execer.new(params[:job_id].to_i, job_inst)
        Sr.log.info("Worker : NEW_JOB : success")
        { :success => true }.to_json
      end

      get_or_post "/#{Sr::MessageTypes::KILL_JOB}" do
        # remove reducer from the pool of reducers in this node
        result = Worker::remove_execer(params[:job_id].to_i)
        { :success => result }.to_json
      end

      get_or_post "/#{Sr::MessageTypes::PUSH_RESULTS}" do
        Sr.log.info(request.path)
        # get result of computation as understood by this reducer
        execer = Worker::execers[params[:job_id].to_i]
        result = execer.nil? ? nil : Array.new(execer.results)
        # blank the reuslts
        execer.results.clear
        { :success => !execer.nil?, :result => result }.to_json
      end

      get_or_post "/#{Sr::MessageTypes::RECEIVE_FETCH}" do
        Sr.log.info(request.path)
        # get result of computation as understood by this reducer
        execer = Worker::execers[params[:job_id].to_i]
        return { :success => false }.to_json if execer.nil?
        execer.compute(JSON.parse(params[:datum]))
        { :success => true }.to_json
      end

    end

    def self.start_server
      # contact master and tell it a new collector is up
      Sr::Util.send_message(Sr::node.master, Sr::MessageTypes::WORKER_CREATED,
                            { :ipaddr => Sr::node.ipaddr,
                              :port => Sr::node.worker_port,
                              :uuid => Sr::UUID })
      Server.run! :port => Sr::node.worker_port
    end
  end
end

