module Rapport
  # Where a Timeline entry points when clicked: the Stripe dashboard for money,
  # the Resend log for mail, and the host's own engines for chat, feedback and
  # testimonials. Each link is a lambda taking the entry and returning a URL or
  # nil, so a host can replace any of them in the initializer.
  module EntryLinks
    module_function

    def defaults
      {
        "charge"             => ->(entry) { stripe("payments/#{entry.payload['processor_id']}") if entry.payload["processor_id"].present? },
        "subscription"       => ->(entry) { stripe("subscriptions/#{entry.payload['processor_id']}") if entry.payload["processor_id"].present? },
        "subscription_ended" => ->(entry) { stripe("subscriptions/#{entry.payload['processor_id']}") if entry.payload["processor_id"].present? },
        "email"              => ->(_entry) { "https://resend.com/emails" },
        "chat"               => ->(entry) { mounted("Livechat::Engine") { |r, at| r.conversation_path(entry.source_id, script_name: at) } },
        "feedback"           => ->(entry) { mounted("Ideasbugs::Engine") { |r, at| r.feedback_path(entry.source_id, script_name: at) } },
        "testimonial"        => ->(entry) { mounted("Testimonials::Engine") { |r, at| r.testimonial_path(entry.source_id, script_name: at) } },
        "nps"                => ->(entry) { mounted("Testimonials::Engine") { |r, at| r.nps_response_path(entry.source_id, script_name: at) } }
      }
    end

    def default_user_link
      ->(contact) { mounted("Avo::Engine") { |r, at| r.resources_user_path(contact.user_id, script_name: at) } }
    end

    # Stripe's dashboard has a separate URL space for test-mode data.
    def stripe(path)
      test = defined?(::Stripe) && ::Stripe.api_key.to_s.start_with?("sk_test")
      "https://dashboard.stripe.com/#{'test/' if test}#{path}"
    end

    # A path inside another engine mounted on the host, or nil if it is absent.
    # Yields the engine's URL helpers and the path it is mounted at.
    def mounted(engine_name)
      engine = engine_name.safe_constantize or return nil
      at = mount_path(engine) or return nil

      yield engine.routes.url_helpers, at
    rescue NoMethodError, ActionController::UrlGenerationError
      nil
    end

    def mount_path(engine)
      route = Rails.application.routes.routes.find { |r| r.app.respond_to?(:app) && r.app.app == engine }
      route&.path&.spec&.to_s
    end
  end
end
