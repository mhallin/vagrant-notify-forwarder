module VagrantNotifyForwarderPlugin
  module Config

    class Config < Vagrant.plugin("2", :config)
      attr_accessor :port
      attr_accessor :enable

      def initialize
        @port = UNSET_VALUE
        @enable = UNSET_VALUE
      end

      def finalize!
        @port = 29324 if @port == UNSET_VALUE
        @enable = true if @enable == UNSET_VALUE
      end
    end

  end
end
