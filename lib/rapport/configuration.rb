module Rapport
  # Defaults match a conventional Rails SaaS shell (User, Account, Pay, Ahoy, plus the
  # ideasbugs, livechat and testimonials engines) so a host initializer can stay small.
  class Configuration
    HOST_CLASSES = %i[
      user_class account_class subscription_class charge_class
      ahoy_event_class livechat_conversation_class testimonial_class nps_response_class feedback_class
    ].freeze

    attr_accessor :mount_path, :parent_controller, :layout, :authenticate, :skip_host_before_actions, :skip_user, :entry_links, :user_link, *HOST_CLASSES

    def link_for(entry)
      @entry_links[entry.kind]&.call(entry)
    end

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
      # Timeline entry kind => lambda(entry) returning a URL or nil. See EntryLinks.
      @entry_links = EntryLinks.defaults
      # lambda(contact) returning where "user #n" points, or nil.
      @user_link = EntryLinks.default_user_link
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
