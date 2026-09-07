module Rapport
  # One row per thing that happened with a Contact, from any Source. Keyed by
  # source type and id so the Sweep can upsert without duplicating.
  class TimelineEntry < ApplicationRecord
    belongs_to :contact

    validates :kind, :occurred_at, :title, :source_type, :source_id, presence: true

    scope :newest_first, -> { order(occurred_at: :desc, id: :desc) }

    # Idempotent write. `source` may be a record or a [type, id] pair.
    def self.record!(contact:, kind:, occurred_at:, title:, source:, payload: {}, status: nil)
      source_type, source_id = source.is_a?(Array) ? source : [ source_type_for(source), source.id ]
      entry = find_or_initialize_by(contact:, source_type:, source_id: source_id.to_s)
      entry.assign_attributes(kind:, occurred_at:, title: title.to_s.truncate(255), payload:, status: status || entry.status)
      entry.save! if entry.new_record? || entry.changed?
      entry
    end

    # STI subclasses (Pay::Stripe::Subscription) key by their base class so the
    # Timeline does not care which processor produced the row.
    def self.source_type_for(record)
      klass = record.class
      klass = klass.base_class if klass.respond_to?(:base_class)
      klass.name
    end
  end
end
