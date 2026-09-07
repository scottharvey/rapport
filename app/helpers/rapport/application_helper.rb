module Rapport
  module ApplicationHelper
    STAGE_VARIANTS = {
      "lead" => :neutral, "signed_up" => :info, "trialing" => :warning, "subscribed" => :success, "churned" => :error
    }.freeze

    # Keeps LastPass and 1Password from decorating fields that are not logins.
    def plain_field
      { "data-lpignore" => "true", "data-1p-ignore" => "", autocomplete: "off" }
    end

    def contact_initials(contact)
      words = contact.name.to_s.split
      return contact.primary_email.to_s.first(2).upcase if words.empty?

      words.first(2).map { |w| w[0] }.join.upcase
    end

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
        [ "Overdue by #{days_between(contact.due_at, Time.current)}", cadence, true ]
      else
        [ "Due in #{days_between(Time.current, contact.due_at)}", cadence, false ]
      end
    end

    def days_between(from, to)
      days = ((to - from) / 1.day).ceil
      days < 1 ? "less than a day" : "#{days} #{'day'.pluralize(days)}"
    end
  end
end
