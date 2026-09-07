module Rapport
  module ApplicationHelper
    STAGE_VARIANTS = {
      "lead" => :neutral, "signed_up" => :info, "trialing" => :warning, "subscribed" => :success, "churned" => :error
    }.freeze

    def stage_badge(stage)
      render Ui::BadgeComponent.new(variant: STAGE_VARIANTS.fetch(stage, :neutral), soft: true, size: :sm, text: stage.humanize)
    end

    def rapport_time(time)
      return "" if time.nil?

      tag.time(time.strftime("%-d %b %Y"), datetime: time.iso8601, title: time.strftime("%-d %b %Y %H:%M"))
    end

    # "3 days ago" with the exact date on hover.
    def rapport_ago(time)
      return "" if time.nil?

      tag.time("#{time_ago_in_words(time)} ago", datetime: time.iso8601, title: time.strftime("%-d %b %Y %H:%M"))
    end

    # One line describing the Reminder state, and whether it needs attention.
    def touch_status(contact)
      return nil if contact.reminder_cadence_days.nil?

      cadence = "every #{contact.reminder_cadence_days}d"
      if contact.last_touched_at.nil?
        [ "Never touched", cadence, true ]
      elsif contact.due?
        [ "Overdue by #{distance_of_time_in_words(contact.due_at, Time.current)}", cadence, true ]
      else
        [ "Due in #{distance_of_time_in_words(Time.current, contact.due_at)}", cadence, false ]
      end
    end
  end
end
