module VagrantPlugins
  module VagrantNotifyForwarder
    class Config < Vagrant.plugin(2, :config)
      attr_accessor :port
      attr_accessor :enable
      attr_accessor :run_as_root

      def initialize
        @port = UNSET_VALUE
        @enable = UNSET_VALUE
        @run_as_root = UNSET_VALUE
      end

      def finalize!
        @port = 29324 if @port == UNSET_VALUE
        @enable = true if @enable == UNSET_VALUE
        @run_as_root = true if @run_as_root == UNSET_VALUE
      end
    end
  end
end
