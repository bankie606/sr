require "sr"

require "json"
require "sinatra/base"

module Sr
  module Master

    class Server < Sinatra::Base
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

