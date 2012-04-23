require "sr"

require "json"
require "uri"
require "net/http"
require 'socket'

module Sr
  class Util
    class << self

      # send a message over http and return the response body
      def send_message(destination, message_type, params)
        req_uri = "http://#{destination}/#{message_type}"
        JSON.parse(Net::HTTP.post_form(URI.parse(req_uri), params).read_body)
      end

      # http://coderrr.wordpress.com/2008/05/28/get-your-local-ip-address/
      def local_ip
        # turn off reverse DNS resolution temporarily
        orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true

        UDPSocket.open do |s|
          s.connect '64.233.187.99', 1
          s.addr.last
        end
      ensure
        Socket.do_not_reverse_lookup = orig
      end

      def eval_jobfile(jobfile)
        jobfile_src = jobfile
        job_class = eval(jobfile_src)
        job_inst = job_class.new
      end
    end
  end
end

