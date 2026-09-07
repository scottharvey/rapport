module Rapport
  class Company < ApplicationRecord
    has_many :contacts, dependent: :nullify

    # Forms post the name as `label`: password managers treat any input
    # called "name" as a form-fill target, whatever attributes it carries.
    alias_attribute :label, :name

    normalizes :domain, with: ->(d) { d.to_s.strip.downcase.delete_prefix("@").presence }

    validates :name, presence: true

    scope :alphabetical, -> { order(:name) }

    def self.for_domain(domain)
      return nil if domain.blank?

      where(domain: domain.to_s.downcase).first
    end

    def account
      return nil unless account_id

      Rapport.host_class(:account_class)&.find_by(id: account_id)
    end

    # Pay subscriptions on the linked Account, across all its customers.
    def self.subscriptions_for(account)
      return [] unless account.respond_to?(:pay_customers)

      account.pay_customers.flat_map { |customer| customer.subscriptions.to_a }
    end

    def subscriptions
      self.class.subscriptions_for(account)
    end
  end
end
