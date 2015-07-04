require "vagrant"

module VagrantNotifyForwarderPlugin

  class Plugin < Vagrant.plugin("2")
    name "vagrant-notify-forwarder"
    description "Wrapper around the notify-forwarder file system event forwarder"

    register_boot_hooks = lambda do |hook|
      require_relative "vagrant-notify-forwarder/action"

      hook.after Vagrant::Action::Builtin::Provision,
                 VagrantNotifyForwarderPlugin::Action::StartHostForwarder
      hook.after VagrantNotifyForwarderPlugin::Action::StartHostForwarder,
                 VagrantNotifyForwarderPlugin::Action::StartClientForwarder
    end

    register_halt_hooks = lambda do |hook|
      require_relative "vagrant-notify-forwarder/action"

      hook.before Vagrant::Action::Builtin::GracefulHalt,
                  VagrantNotifyForwarderPlugin::Action::StopHostForwarder
    end

    config "notify_forwarder" do
      require_relative "vagrant-notify-forwarder/config"

      VagrantNotifyForwarderPlugin::Config::Config
    end

    action_hook :start_notify_forwarder, :machine_action_up, &register_boot_hooks
    action_hook :start_notify_forwarder, :machine_action_reload, &register_boot_hooks

    action_hook :stop_notify_forwarder, :machine_action_halt, &register_halt_hooks
    action_hook :stop_notify_forwarder, :machine_action_reload, &register_halt_hooks

  end

end
