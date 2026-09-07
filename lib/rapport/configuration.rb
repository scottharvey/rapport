module Rapport
  # Defaults match the Launchpad shell so the host initializer can stay empty.
  class Configuration
    HOST_CLASSES = %i[
      user_class account_class subscription_class charge_class
      ahoy_event_class livechat_conversation_class testimonial_class nps_response_class feedback_class
    ].freeze

    attr_accessor :mount_path, :parent_controller, :layout, :authenticate, :skip_host_before_actions, :skip_user, *HOST_CLASSES

    def initialize
      @mount_path = "/rapport"
      @parent_controller = "::ApplicationController"
      @layout = "hub"
      @skip_host_before_actions = %i[require_authentication redirect_to_onboarding_if_needed sync_stripe_checkout_session require_active_subscription]
      @user_class = "User"
      @account_class = "Account"
      @subscription_class = "Pay::Subscription"
      @charge_class = "Pay::Charge"
      @ahoy_event_class = "Ahoy::Event"
      @livechat_conversation_class = "Livechat::Conversation"
      @testimonial_class = "Testimonials::Testimonial"
      @nps_response_class = "Testimonials::NpsResponse"
      @feedback_class = "Ideasbugs::Feedback"
      # Operators are not Contacts. Admin Users are left out of the Sweep.
      @skip_user = ->(user) { user.respond_to?(:admin?) && user.admin? }
      # Runs in the controller. Redirects anyone who is not a signed-in admin.
      @authenticate = lambda do
        resume_session if respond_to?(:resume_session, true)
        user = Current.user if defined?(::Current)
        unless user&.admin?
          redirect_to(user ? main_app.root_path : main_app.new_session_path)
        end
      end
    end
  end
end
