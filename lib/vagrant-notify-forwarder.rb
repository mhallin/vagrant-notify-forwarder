require 'vagrant-notify-forwarder/plugin'
require 'vagrant-notify-forwarder/config'

module VagrantPlugins
  module VagrantNotifyForwarder
    def self.source_root
      @source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
    end
  end
end
