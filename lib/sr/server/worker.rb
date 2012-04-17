require "sr"

require "json"
require "sinatra/base"

module Sr
  module Worker

    class Server < Sinatra::Base
      get "/#{Sr::MessageTypes::NEW_JOB}" do
        # create execer and add it to the pool of execers in this node
        # TODO: document what init block is expected to setup
        Execer.new(params[:job_id].to_i, eval(params[:init_block]))
        { :success => true }.to_json
      end

      get "/#{Sr::MessageTypes::KILL_JOB}" do
        # remove reducer from the pool of reducers in this node
        result = Worker::remove_execer(params[:job_id].to_i)
        { :success => result }.to_json
      end

      get "/#{Sr::MessageTypes::PUSH_RESULTS}" do
        # get result of computation as understood by this reducer
        execer = Worker::execers[params[:job_id].to_i]
        # TODO: work out how the execer will store and push its results
        # currently compute just returns the result and doesn't do anything
        # with it
        result = execer.nil? ? nil : execer
        { :success => execer.nil?, :result => result }.to_json
      end
    end

    def self.start_server
      Server.run! :port => Sr::node.worker_port
      # contact master and tell it a new collector is up
      Sr::Util.send_message(Sr::node.master, Sr::MessageTypes::WORKER_CREATED,
                            { :ipaddr => Sr::node.ipaddr,
                              :port => Sr::node.worker_port })
    end
  end
end

