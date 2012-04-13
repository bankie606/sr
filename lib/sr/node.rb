require "sr"

module Sr
  def self.node=(node)
    @node = node
  end

  def self.node
    @node
  end

  class Node
    attr_accessor :ipaddr
    attr_accessor :fetcher_port, :worker_port, :collector_port
    attr_accessor :master_loc, :master_port

    def master
      "#{@master_loc}:#{@master_port}"
    end
  end
end

