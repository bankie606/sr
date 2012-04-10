require "sr"

module Sr
  class Node
    attr_accessor :ipaddr
    attr_accessor :fetcher_port, :worker_port, :collector_port
  end
end

