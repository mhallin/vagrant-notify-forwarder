module VagrantPlugins
  module VagrantNotifyForwarder
    module Action
      class CheckBootState
        def initialize(app, env)
          @app = app
        end

        def call(env)
          return unless env[:machine].config.notify_forwarder.enable
          $BOOT_SAVED = env[:machine].state.id == :saved

          @app.call env
        end
      end
    end
  end
end
