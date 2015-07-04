# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-notify-forwarder/version'

Gem::Specification.new do |spec|
  spec.name          = "vagrant-notify-forwarder"
  spec.version       = VagrantNotifyForwarderPlugin::VERSION
  spec.authors       = ["Magnus Hallin"]
  spec.email         = ["mhallin@gmail.com"]
  spec.summary       = "A vagrant plugin that forwards file system events from the host to the guest"
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/mhallin/vagrant-notify-forwarder"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.require_paths = ["lib"]
end
