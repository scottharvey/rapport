module Rapport
  # One row of a Contact's Timeline. Reads only the entry's kind, title, time,
  # status and payload, so any Source renders the same way.
  class TimelineEntryComponent < ViewComponent::Base
    ICONS = {
      "note" => "pencil-square", "interaction" => "chat-bubble-left-right", "touched" => "check-circle",
      "email" => "document-text", "chat" => "chat-bubble-left-right", "charge" => "chart-bar",
      "subscription" => "sparkles", "subscription_ended" => "x-circle", "event" => "queue-list",
      "testimonial" => "star", "nps" => "star", "feedback" => "exclamation-triangle", "user_deleted" => "trash"
    }.freeze

    def initialize(entry:)
      @entry = entry
    end

    private

    attr_reader :entry

    def icon_name
      ICONS.fetch(entry.kind, "information-circle")
    end

    def detail
      payload = entry.payload || {}
      case entry.kind
      when "note", "interaction" then payload["body"]
      when "email" then [ payload["mailer"], entry.status ].compact.join(" · ")
      when "chat", "feedback" then payload["page_url"]
      when "testimonial", "nps" then payload["comment"] || payload["body"]
      when "subscription" then [ payload["plan"], payload["trial_ends_at"] && "trial ends #{payload['trial_ends_at'].to_s.first(10)}" ].compact.join(" · ")
      end
    end

    def timestamp
      entry.occurred_at.strftime("%-d %b %Y %H:%M")
    end
  end
end
