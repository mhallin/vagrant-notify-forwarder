module VagrantNotifyForwarderPlugin

  module Action

    class Utils
      @@OS_NAMES = {
        "Linux" => :linux,
        "Darwin" => :darwin,
        "FreeBSD" => :freebsd,
      }

      @@HARDWARE_NAMES = {
        "x86_64" => :x86_64,
      }

      def self.parse_os_name(data)
        @@OS_NAMES[data.strip] or :unsupported
      end

      def self.parse_hardware_name(data)
        @@HARDWARE_NAMES[data.strip] or :unsupported
      end

      def self.host_pidfile(env)
        env[:machine].data_dir.join('notify_watcher_host_pid')
      end

      def self.ensure_binary_downloaded(env, os, hardware)
        download_urls = {
          [:linux, :x86_64] => ['https://github.com/mhallin/notify-forwarder/releases/download/release/v0.1.0/notify-forwarder_linux_x64',
                                '7d14996963f45d9b1c85e78d0aa0c94371d585d0ccabae482c2ef5968417a7f0'],
          [:darwin, :x86_64] => ['https://github.com/mhallin/notify-forwarder/releases/download/release/v0.1.0/notify-forwarder_osx_x64',
                                 'd8ad61d9b70394b55bc22c94771ca6f88f0f51868617c3b2c55654ebde866c23'],
          [:freebsd, :x86_64] => ['https://github.com/mhallin/notify-forwarder/releases/download/release/v0.1.0/notify-forwarder_freebsd_x64',
                                  '2df0884958b2469dd7113660cf2de01e9e5dd8fcad0213bff3335833e6668f84'],
        }

        url, sha256sum = download_urls[[os, hardware]]
        path = env[:tmp_path].join File.basename(url)
        should_download = true

        if File.exists? path
          digest = Digest::SHA256.file(path).hexdigest

          if digest == sha256sum
            should_download = false
          end
        end

        if should_download
          env[:ui].info 'Notify-forwarder: Downloading client'
          downloader = Vagrant::Util::Downloader.new url, path
          downloader.download!
        end

        File.chmod(0755, path)

        path
      end
    end

    class StartHostForwarder
      def initialize(app, env)
        @app = app
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

        pidfile = Utils.host_pidfile env
        pidfile.open('w+') do |f|
          f.write(pid)
        end
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

          args = "watch -c 127.0.0.1:#{port}"

          env[:machine].config.vm.synced_folders.each do |id, options|
            unless options[:disabled]
              hostpath = File.absolute_path(options[:hostpath])
              guestpath = options[:guestpath]

              args += " #{hostpath} #{guestpath}"
            end
          end

          start_watcher env, "#{path} #{args}"
        end
      end
    end

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
            pid = f.read.to_i

            begin
              Process.kill 'TERM', pid
            rescue Errno::ESRCH
            end
          end
        end
      end
    end

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

        env[:machine].communicate.upload(path, "/tmp/notify-forwarder")
        env[:machine].communicate.execute("nohup /tmp/notify-forwarder receive -p #{port} &")
      end
    end

  end

end
