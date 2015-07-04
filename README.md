# Vagrant file system notification forwarder plugin

A vagrant plugin that uses [notify-forwarder](https://github.com/mhallin/notify-forwarder) to
forward file system events from the host to the guest automatically on all shared folders.

This is useful for auto reloading file systems that rebuild when files change. Normally, they have
to use CPU intensive polling when watching shared folders. This plugin makes them able to use
inotify or similar for improved performance and reduced CPU usage.

## Installation and usage

```terminal
$ vagrant plugin install vagrant-notify-forwarder
$ vagrant reload
```

By default, this sets up UDP port 29324 for port forwarding. If you're already using this port, or
if you want to change it, add the following line to your `Vagrantfile`:

```ruby
config.notify_forwarder.port = 22020 # Or your port number
```

The server and guest binaries will be automatically downloaded from the notify-forwarder repo's
releases and verified with SHA256.

## Supported operating systems

To conserve size and dependencies, the plugin downloads binaries for supported platforms. This
plugin supports the same host/guest platforms as `notify-forwarder` itself:

* FreeBSD 64 bit as guest,
* Linux 64 bit as host and guest, and
* Mac OS X 64 bit as host and guest.

If you're running an unsupported host or guest and want to disable this plugin for a specific
machine, add the following line to your `Vagrantfile`:

```ruby
config.notify_forwarder.enable = false
```
