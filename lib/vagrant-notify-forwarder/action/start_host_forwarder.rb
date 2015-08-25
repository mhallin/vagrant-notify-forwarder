require 'vagrant-notify-forwarder/utils'
require 'vagrant-notify-forwarder/pid_handler'

module VagrantPlugins
  module VagrantNotifyForwarder
    module Action
      class StartHostForwarder
        def initialize(app, env)
          @app = app
          @pid_handler = PidHandler.instance
        end

        def ensure_binary_downloaded(env)
          os = Utils.parse_os_name `uname -s`
          hardware = Utils.parse_hardware_name `uname -m`

          env[:ui].error 'Notify-forwarder: Unsupported host operating system' if os == :unsupported
          env[:ui].error 'Notify-forwarder: Unsupported host hardware' if hardware == :unsupported

          if os != :unsupported and hardware != :unsupported
            Utils.ensure_binary_downloaded env, os, hardware
          end
        end

        def start_watcher(env, command)
          pid = Process.spawn command
          Process.detach(pid)
          @pid_handler.pids << pid
          env[:ui].info "PIDS ARE #{@pid_handler.pids}"
        end

        def call(env)
          if env[:machine].config.notify_forwarder.enable
            port = env[:machine].config.notify_forwarder.port
            env[:machine].config.vm.network :forwarded_port, host: port, guest: port, protocol: 'udp'
          end

          @app.call env

          if env[:machine].config.notify_forwarder.enable
            path = ensure_binary_downloaded env
            return unless path

            env[:machine].config.vm.synced_folders.each do |id, options|
              unless options[:disabled]
                hostpath = File.absolute_path(options[:hostpath])
                guestpath = options[:guestpath]

                args = "watch -c 127.0.0.1:#{port} #{hostpath} #{guestpath}"
                start_watcher env, "#{path} #{args}"
              end
            end
          end
        end
      end
    end
  end
end