require "sr"

require "sinatra/base"

module Sr
  module Collector
    attr_accessor :collector_port

    class Server < Sinatra::Base
      POST "/new-job" do
        # create reducer and add it to the pool of reducers in this node
        Reducer.new(params[:job_id].to_i, eval(params[:combine_block]))
      end
    end

    def self.start_server(port)
      @collector_port = port # save this for later
      Server.run! :port => port
      # TODO: contact master and tell it a new collector is up
    end
  end
end

