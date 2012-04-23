require "sr"

require "json"
require "sinatra/base"

module Sr
  module Collector

    class Server < Sinatra::Base
      def self.get_or_post(path, opts={}, &block)
        get(path, opts, &block)
        post(path, opts, &block)
      end

      get_or_post "/#{Sr::MessageTypes::NEW_JOB}" do
        # eval the jobfile and instantiate it
        job_inst = Sr::Util.eval_jobfile(params[:jobfile])

        # create reducer and add it to the pool of reducers in this node
        Reducer.new(params[:job_id].to_i, job_inst)
        Sr.log.info("Collector : NEW_JOB : success")
        { :success => true }.to_json
      end

      get_or_post "/#{Sr::MessageTypes::KILL_JOB}" do
        # remove reducer from the pool of reducers in this node
        result = Collector::remove_reducer(params[:job_id].to_i)
        { :success => result }.to_json
      end

      get_or_post "/#{Sr::MessageTypes::RESULT}" do
        # get result of computation as understood by this reducer
        reducer = Collector::reducers[params[:job_id].to_i]
        result = reducer.nil? ? nil : reducer.val
        { :success => !reducer.nil?, :result => result }.to_json
      end

      get_or_post "/#{Sr::MessageTypes::GET_WORKER_RESULTS}" do
        # get result of computation as understood by this reducer
        reducer = Collector::reducers[params[:job_id].to_i]
        return { :success => false } if reducer.nil?
        reducer.merge_results_from_worker(JSON.parse(params[:results]))
        { :success => true }
      end
    end

    def self.start_server
      # contact master and tell it a new collector is up
      Sr::Util.send_message(Sr::node.master, Sr::MessageTypes::COLLECTOR_CREATED,
                            { :ipaddr => Sr::node.ipaddr,
                              :port => Sr::node.collector_port,
                              :uuid => Sr::UUID })
      Server.run! :port => Sr::node.collector_port
    end
  end
end

