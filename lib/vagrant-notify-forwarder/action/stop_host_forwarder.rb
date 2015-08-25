require 'vagrant-notify-forwarder/utils'
require 'vagrant-notify-forwarder/pid_handler'

module VagrantPlugins
  module VagrantNotifyForwarder
    module Action
      class StopHostForwarder
        def initialize(app, env)
          @app = app
          @pid_handler = PidHandler.instance
        end

        def call(env)
          @app.call env

          return unless env[:machine].config.notify_forwarder.enable
          env[:ui].info "Processes to stop are #{@pid_handler.pids}"
          @pid_handler.pids.each { |pid|
            begin
              env[:ui].info "Stopping process #{pid}"
              Process.kill 'TERM', pid
            rescue Errno::ESRCH
            end
          }

          @pid_handler.pids = []
        end
      end
    end
  end
end