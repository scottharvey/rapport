module Rapport
  class Interaction < ApplicationRecord
    KINDS = %w[meeting call email message].freeze

    has_many :interaction_participants, dependent: :destroy
    has_many :contacts, through: :interaction_participants

    validates :kind, inclusion: { in: KINDS }
    validates :occurred_at, presence: true

    # Logging an Interaction is a Touch for everyone who took part.
    def record!(contacts_to_add = [])
      transaction do
        save!
        Array(contacts_to_add).each { |contact| interaction_participants.find_or_create_by!(contact:) }
        contacts.reload.each do |contact|
          contact.touch!(at: occurred_at)
          TimelineEntry.record!(contact:, kind: "interaction", occurred_at:, title: "#{kind.humanize}#{": #{body.truncate(80)}" if body.present?}",
                                payload: { interaction_kind: kind, body: body }, source: self)
        end
      end
      self
    end
  end
end
