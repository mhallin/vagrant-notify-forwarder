require 'vagrant/util/downloader'

module VagrantPlugins
  module VagrantNotifyForwarder
    class Utils
      @@OS_NAMES = {
          "Linux" => :linux,
          "Darwin" => :darwin,
          "FreeBSD" => :freebsd,
      }

      @@HARDWARE_NAMES = {
          "x86_64" => :x86_64,
          "amd64" => :x86_64,
      }

      def self.parse_os_name(data)
        @@OS_NAMES[data.strip] or :unsupported
      end

      def self.parse_hardware_name(data)
        @@HARDWARE_NAMES[data.strip] or :unsupported
      end

      def self.ensure_binary_downloaded(env, os, hardware)
        download_urls = {
            [:linux, :x86_64] => %w(https://github.com/mhallin/notify-forwarder/releases/download/release/v0.1.1/notify-forwarder_linux_x64
                                fc00ce7e30ae87daa10fb3bc4d77e06571998b408ff79a4aef3189f5210dc914),
            [:darwin, :x86_64] => %w(https://github.com/mhallin/notify-forwarder/releases/download/release/v0.1.1/notify-forwarder_osx_x64
                                 317f3ffea15393668bf04b128cef1545031eaf306eeb2c4a345a95d8c6e1c941),
            [:freebsd, :x86_64] => %w(https://github.com/mhallin/notify-forwarder/releases/download/release/v0.1.1/notify-forwarder_freebsd_x64
                                  082ceac8f5fbda6abc5e2872a6c748241f243f2d780c96d50b3f11f8e96ca65b),
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

      def self.host_pidfile(env)
        env[:machine].data_dir.join('notify_watcher_host_pid')
      end
    end
  end
end
