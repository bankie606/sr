require "sr"

require "thread"

module Sr
  module Messaging
    class Queue
      attr_accessor :q
      attr_accessor :name

      def initialize(name)
        @name = name
        @q = Array.new
        @mutex = Mutex.new
      end

      def add(obj)
        @mutex.synchronize { @q << obj }
      end

      def remove
        @mutex.synchronize { @q.shift }
      end
    end
  end
end

