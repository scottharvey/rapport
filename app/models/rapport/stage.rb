module Rapport
  # Where a Contact sits in the buying lifecycle, derived from the linked User
  # and their Subscription. The hand-set Stage only counts while no User is linked.
  module Stage
    ACTIVE = %w[active].freeze
    TRIAL = %w[trialing].freeze

    def self.derive(contact)
      return contact.manual_stage || "lead" if contact.user_id.nil? && !contact.timeline_entries.exists?(kind: "user_deleted")
      return "churned" if contact.user_id.nil?

      subscriptions = subscriptions_for(contact)
      return "signed_up" if subscriptions.empty?
      return "trialing" if subscriptions.any? { |s| TRIAL.include?(s.status) }
      return "subscribed" if subscriptions.any? { |s| ACTIVE.include?(s.status) && !s.on_trial? }

      "churned"
    end

    def self.subscriptions_for(contact)
      user = contact.user or return []
      accounts = user.respond_to?(:accounts) ? user.accounts : []
      accounts.flat_map { |account| Company.subscriptions_for(account) }
    end
  end
end
