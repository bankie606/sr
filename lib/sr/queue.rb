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

      def removeAll
        @mutex.synchronize do
          results = Array.new(@q)
          @q.clear
          results
        end
      end

      def removeN(n)
        @mutex.synchronize do
          results = Array.new
          n.times do |i|
            r = @q.shift
            results << r if !r.nil?
          end
          results
        end
      end
    end
  end
end

