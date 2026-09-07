module Rapport
  class Engine < ::Rails::Engine
    isolate_namespace Rapport

    # Migrations stay in the engine; the host runs them from here.
    initializer "rapport.migrations" do |app|
      unless app.root.to_s.start_with?(root.to_s)
        config.paths["db/migrate"].expanded.each do |path|
          app.config.paths["db/migrate"] << path
        end
      end
    end

    # Outgoing mail is the one host activity the Sweep cannot see in a table.
    initializer "rapport.mail_observer" do
      ActiveSupport.on_load(:action_mailer) do
        require "rapport/mail_observer"
        register_observer Rapport::MailObserver
      end
    end

    initializer "rapport.lookbook" do |app|
      if defined?(::Lookbook)
        app.config.lookbook.preview_paths << root.join("test/components/previews").to_s
      end
    end
  end
end
