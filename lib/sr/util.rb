require "sr"

require "uri"
require "net/http"

module Sr
  class Util
    class << self

      # send a message over http and return the response body
      def send_message(destination, message_type, params)
        req_uri = "#{destination}/#{message_type}?"
        params.each_pair do |k,v|
          req_uri += "#{k}=#{v}&"
        end
        Net::HTTP.get_response(URI.parse(req_uri)).read_body
      end
    end
  end
end

