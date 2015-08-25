require 'vagrant-notify-forwarder/utils'

module VagrantPlugins
  module VagrantNotifyForwarder
    module Action
      class StopHostForwarder
        def initialize(app, env)
          @app = app
        end

        def call(env)
          @app.call env

          return unless env[:machine].config.notify_forwarder.enable

          pidfile = Utils.host_pidfile env

          if File.exists? pidfile
            pidfile.open('r') do |f|
              f.readlines.each do |process|
                pid = process.to_i
                begin
                  Process.kill 'TERM', pid
                rescue Errno::ESRCH
                end
              end
              pidfile.delete
            end
          end
        end
      end
    end
  end
end