require "sr"

require "json"
require "sinatra/base"

module Sr
  module Fetcher

    class Server < Sinatra::Base
      def self.get_or_post(path, opts={}, &block)
        get(path, opts, &block)
        post(path, opts, &block)
      end

      get_or_post "/#{Sr::MessageTypes::NEW_JOB}" do
        # eval the jobfile and instantiate it
        job_inst = Sr::Util.eval_jobfile(params[:jobfile])

        # create spout and add it to the pool of spouts in this node
        Spout.new(params[:job_id].to_i, job_inst)
        Sr.log.debug("Fetcher : NEW_JOB : success")
        { :success => true }.to_json
      end

      get_or_post "/#{Sr::MessageTypes::KILL_JOB}" do
        # remove spout from the pool of spouts in this node
        result = Fetcher::remove_spout(params[:job_id].to_i)
        { :success => result }.to_json
      end

      get_or_post "/#{Sr::MessageTypes::FETCH}" do
        # fetch next datum
        spout = Fetcher::spouts[params[:job_id].to_i]
        result = spout.nil? ? nil : spout.fetch
        { :success => !spout.nil? && !result.nil?, :result => result }.to_json
      end
    end

    def self.start_server
      # contact master and tell it a new fetcher is up
      Sr::Util.send_message(Sr::node.master, Sr::MessageTypes::FETCHER_CREATED,
                            { :ipaddr => Sr::node.ipaddr,
                              :port => Sr::node.fetcher_port,
                              :uuid => Sr::UUID })
      Server.run! :port => Sr::node.fetcher_port
    end
  end
end

