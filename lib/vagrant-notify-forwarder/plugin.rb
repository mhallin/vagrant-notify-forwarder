require 'vagrant'

$BOOT_SAVED = false

module VagrantPlugins
  module VagrantNotifyForwarder
    class Plugin < Vagrant.plugin('2')
      name 'vagrant-notify-forwarder'
      description 'Wrapper around the notify-forwarder file system event forwarder'

      register_boot_hooks = lambda do |hook|
        require_relative 'action/start_host_forwarder'
        # require_relative 'action/stop_host_forwarder'
        require_relative 'action/start_client_forwarder'
        require_relative 'action/check_boot_state'

        hook.before VagrantPlugins::ProviderVirtualBox::Action::Resume,
                    VagrantPlugins::VagrantNotifyForwarder::Action::CheckBootState
        hook.after Vagrant::Action::Builtin::Provision,
                   VagrantPlugins::VagrantNotifyForwarder::Action::StartHostForwarder
        hook.after VagrantPlugins::VagrantNotifyForwarder::Action::StartHostForwarder,
                   VagrantPlugins::VagrantNotifyForwarder::Action::StartClientForwarder
      end

      register_suspend_hooks = lambda do |hook|
        require_relative 'action/stop_host_forwarder'

        hook.before VagrantPlugins::ProviderVirtualBox::Action::Suspend,
                    VagrantPlugins::VagrantNotifyForwarder::Action::StopHostForwarder
      end

      register_resume_hooks = lambda do |hook|
        require_relative 'action/start_host_forwarder'

        hook.after VagrantPlugins::ProviderVirtualBox::Action::Provision,
                    VagrantPlugins::VagrantNotifyForwarder::Action::StartHostForwarder
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

      action_hook :stop_notify_forwarder, :machine_action_suspend, &register_suspend_hooks
      action_hook :stop_notify_forwarder, :machine_action_resume, &register_resume_hooks

      action_hook :stop_notify_forwarder, :machine_action_halt, &register_halt_hooks
      action_hook :stop_notify_forwarder, :machine_action_reload, &register_halt_hooks

      action_hook :stop_notify_forwarder, :machine_action_destroy, &register_destroy_hooks

    end
  end
end
