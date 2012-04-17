module Sr
  VERSION = "0.0.1"
  UUID = begin `uuidgen`.strip rescue rand(10000) end
end

require "sr/collector"
require "sr/fetcher"
require "sr/master"
require "sr/node"
require "sr/util"
require "sr/worker"

require "sr/server/message-types"
require "sr/server/collector"
require "sr/server/fetcher"
require "sr/server/master"
require "sr/server/worker"

