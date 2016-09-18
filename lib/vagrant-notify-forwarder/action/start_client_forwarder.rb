require 'vagrant-notify-forwarder/utils'

module VagrantPlugins
  module VagrantNotifyForwarder
    module Action
      class StartClientForwarder
        def initialize(app, env)
          @app = app
        end

        def ensure_binary_downloaded(env)
          os = :unsupported
          hardware = :unsupported

          env[:machine].communicate.execute('uname -s') do |type, data|
            os = Utils.parse_os_name data if type == :stdout
          end

          env[:machine].communicate.execute('uname -m') do |type, data|
            hardware = Utils.parse_hardware_name data if type == :stdout
          end

          env[:ui].error 'Notify-forwarder: Unsupported client operating system' if os == :unsupported
          env[:ui].error 'Notify-forwarder: Unsupported client hardware' if hardware == :unsupported

          if os != :unsupported and hardware != :unsupported
            Utils.ensure_binary_downloaded env, os, hardware
          end
        end

        def call(env)
          @app.call env

          return unless env[:machine].config.notify_forwarder.enable

          path = ensure_binary_downloaded env
          return unless path

          port = env[:machine].config.notify_forwarder.port

          start_command = "nohup /tmp/notify-forwarder receive -p #{port} &"

          if env[:machine].config.notify_forwarder.run_as_root
            start_command = "sudo #{start_command}"
          end

          env[:machine].communicate.upload(path, "/tmp/notify-forwarder")
          env[:ui].output("Starting notify-forwarder ...")
          env[:machine].communicate.execute(start_command)
          env[:ui].detail("Notify-forwarder: guest listening for file change notifications on 0.0.0.0:#{port}.")
        end
      end
    end
  end
end
