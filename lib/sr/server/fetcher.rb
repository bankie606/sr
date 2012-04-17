require "sr"

require "json"
require "sinatra/base"

module Sr
  module Fetcher

    class Server < Sinatra::Base
      get "/#{Sr::MessageTypes::NEW_JOB}" do
        # create spout and add it to the pool of spouts in this node
        Spout.new(params[:job_id].to_i, eval(params[:fetch_block]))
        { :success => true }.to_json
      end

      get "/#{Sr::MessageTypes::KILL_JOB}" do
        # remove spout from the pool of spouts in this node
        result = Fetcher::remove_spout(params[:job_id].to_i)
        { :success => result }.to_json
      end

      get "/#{Sr::MessageTypes::FETCH}" do
        # fetch next datum
        spout = Fetcher::spouts[params[:job_id].to_i]
        result = spout.nil? ? nil : spout.fetch
        { :success => spout.nil?, :result => result }.to_json
      end
    end

    def self.start_server
      Server.run! :port => Sr::node.fetcher_port
      # contact master and tell it a new fetcher is up
      Sr::Util.send_message(Sr::node.master, Sr::MessageTypes::FETCHER_CREATED,
                            { :ipaddr => Sr::node.ipaddr,
                              :port => Sr::node.fetcher_port,
                              :uuid => Sr::UUID })
    end
  end
end

