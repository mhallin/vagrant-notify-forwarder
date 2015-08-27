require 'vagrant'

module VagrantPlugins
  module VagrantNotifyForwarder
    class Plugin < Vagrant.plugin('2')
      name 'vagrant-notify-forwarder'
      description 'Wrapper around the notify-forwarder file system event forwarder'

      register_boot_hooks = lambda do |hook|
        require_relative 'action/start_host_forwarder'
        require_relative 'action/stop_host_forwarder'
        require_relative 'action/start_client_forwarder'

        hook.after Vagrant::Action::Builtin::Provision,
                   VagrantPlugins::VagrantNotifyForwarder::Action::StartHostForwarder
        hook.after VagrantPlugins::VagrantNotifyForwarder::Action::StartHostForwarder,
                   VagrantPlugins::VagrantNotifyForwarder::Action::StartClientForwarder
      end

      register_halt_hooks = lambda do |hook|
        require_relative 'action/stop_host_forwarder'

        hook.before Vagrant::Action::Builtin::GracefulHalt,
                    VagrantPlugins::VagrantNotifyForwarder::Action::StopHostForwarder
      end

      register_destroy_hooks = lambda do |hook|
        require_relative 'action/stop_host_forwarder'

        hook.before Vagrant::Action::Builtin::GracefulHalt,
                    VagrantPlugins::VagrantNotifyForwarder::Action::StopHostForwarder
      end

      config(:notify_forwarder) do
        require_relative 'config'
        Config
      end

      action_hook :start_notify_forwarder, :machine_action_up, &register_boot_hooks
      action_hook :start_notify_forwarder, :machine_action_reload, &register_boot_hooks

      action_hook :stop_notify_forwarder, :machine_action_halt, &register_halt_hooks
      action_hook :stop_notify_forwarder, :machine_action_reload, &register_halt_hooks

      action_hook :stop_notify_forwarder, :machine_action_destroy, &register_destroy_hooks

    end
  end
end