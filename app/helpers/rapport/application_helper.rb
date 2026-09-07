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
  end
end
