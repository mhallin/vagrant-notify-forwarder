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
      }

      def self.parse_os_name(data)
        @@OS_NAMES[data.strip] or :unsupported
      end

      def self.parse_hardware_name(data)
        @@HARDWARE_NAMES[data.strip] or :unsupported
      end

      def self.ensure_binary_downloaded(env, os, hardware)
        download_urls = {
            [:linux, :x86_64] => %w(https://github.com/mhallin/notify-forwarder/releases/download/release/v0.1.0/notify-forwarder_linux_x64
                                7d14996963f45d9b1c85e78d0aa0c94371d585d0ccabae482c2ef5968417a7f0),
            [:darwin, :x86_64] => %w(https://github.com/mhallin/notify-forwarder/releases/download/release/v0.1.0/notify-forwarder_osx_x64
                                 d8ad61d9b70394b55bc22c94771ca6f88f0f51868617c3b2c55654ebde866c23),
            [:freebsd, :x86_64] => %w(https://github.com/mhallin/notify-forwarder/releases/download/release/v0.1.0/notify-forwarder_freebsd_x64
                                  2df0884958b2469dd7113660cf2de01e9e5dd8fcad0213bff3335833e6668f84),
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