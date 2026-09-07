module Rapport
  class Note < ApplicationRecord
    belongs_to :contact

    validates :body, presence: true

    after_create :record_on_timeline

    private

    def record_on_timeline
      TimelineEntry.record!(contact:, kind: "note", occurred_at: created_at, title: body.truncate(80),
                            payload: { body: body }, source: self)
    end
  end
end
