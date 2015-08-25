require 'singleton'

module VagrantPlugins
  module VagrantNotifyForwarder
    class PidHandler
      include Singleton
      attr_accessor :pids

      def initialize
        @pids = []
      end
    end
  end
end