require "sr"

require "json"
require "sinatra/base"

module Sr
  module Collector

    class Server < Sinatra::Base
      get "/#{Sr::MessageTypes::NEW_JOB}" do
        # create reducer and add it to the pool of reducers in this node
        Reducer.new(params[:job_id].to_i, eval(params[:combine_block]))
        { :success => true }.to_json
      end

      get "/#{Sr::MessageTypes::KILL_JOB}" do
        # remove reducer from the pool of reducers in this node
        result = Collector::remove_reducer(params[:job_id].to_i)
        { :success => result }.to_json
      end

      get "/#{Sr::MessageTypes::RESULT}" do
        # get result of computation as understood by this reducer
        reducer = Collector::reducers[params[:job_id].to_i]
        result = reducer.nil? ? nil : reducer.val
        { :success => reducer.nil?, :result => result }.to_json
      end
    end

    def self.start_server
      Server.run! :port => Sr::node.collector_port
      # contact master and tell it a new collector is up
      Sr::Util.send_message(Sr::node.master, Sr::MessageTypes::COLLECTOR_CREATED,
                            { :ipaddr => Sr::node.ipaddr,
                              :port => Sr::node.collector_port,
                              :uuid => Sr::UUID })
    end
  end
end

