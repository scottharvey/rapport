module Rapport
  class Contact < ApplicationRecord
    STAGES = %w[lead signed_up trialing subscribed churned].freeze

    belongs_to :company, optional: true
    has_many :email_addresses, dependent: :destroy
    has_many :taggings, dependent: :destroy
    has_many :tags, through: :taggings
    has_many :notes, dependent: :destroy
    has_many :interaction_participants, dependent: :destroy
    has_many :interactions, through: :interaction_participants
    has_many :timeline_entries, dependent: :destroy

    # The form submits "" for "Lead (default)"; treat blank as unset.
    normalizes :manual_stage, with: ->(s) { s.presence }

    validates :stage, inclusion: { in: STAGES }
    validates :manual_stage, inclusion: { in: STAGES }, allow_nil: true
    validates :reminder_cadence_days, numericality: { greater_than: 0, only_integer: true }, allow_nil: true

    scope :by_stage, ->(stage) { where(stage: stage) }
    scope :recent_first, -> { order(Arel.sql("last_entry_at DESC NULLS LAST"), id: :desc) }
    scope :with_tag, ->(name) { joins(:tags).where(rapport_tags: { name: name }) }
    scope :due, lambda {
      where.not(reminder_cadence_days: nil)
        .where("last_touched_at IS NULL OR last_touched_at < NOW() - (reminder_cadence_days * INTERVAL '1 day')")
        .order(Arel.sql("(last_touched_at + reminder_cadence_days * INTERVAL '1 day') ASC NULLS FIRST"))
    }
    scope :search, lambda { |query|
      q = "%#{sanitize_sql_like(query.to_s.strip)}%"
      left_joins(:email_addresses, :company)
        .where("rapport_contacts.name ILIKE :q OR rapport_email_addresses.address ILIKE :q OR rapport_companies.name ILIKE :q", q: q)
        .distinct
    }

    def self.find_by_email(address)
      return nil if address.blank?

      EmailAddress.find_by(address: EmailAddress.normalize_address(address))&.contact
    end

    def primary_email
      email_addresses.find(&:primary?)&.address || email_addresses.first&.address
    end

    def display_name
      name.presence || primary_email || "Contact ##{id}"
    end

    def user
      return nil unless user_id

      Rapport.host_class(:user_class)&.find_by(id: user_id)
    end

    def add_email(address, primary: false)
      normalized = EmailAddress.normalize_address(address)
      return nil if normalized.blank?

      existing = email_addresses.find { |e| e.address == normalized } || email_addresses.find_by(address: normalized)
      return existing if existing

      email_addresses.update_all(primary: false) if primary
      email_addresses.create!(address: normalized, primary: primary || email_addresses.none?)
    end

    def due?
      return false if reminder_cadence_days.nil?

      last_touched_at.nil? || last_touched_at < reminder_cadence_days.days.ago
    end

    def touch!(at: Time.current)
      update!(last_touched_at: [ last_touched_at, at ].compact.max)
    end

    def refresh_last_entry!
      update_column(:last_entry_at, timeline_entries.maximum(:occurred_at))
    end
  end
end
