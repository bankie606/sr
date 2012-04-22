require "sr"
require "logger"

module Sr
  @logger ||= Logger.new("srlog")
  def self.log
    @logger ||= Logger.new("srlog")
    @logger.level = Logger::INFO
    @logger
  end
end
