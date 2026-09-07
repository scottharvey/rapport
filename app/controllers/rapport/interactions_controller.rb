module Rapport
  class InteractionsController < ApplicationController
    before_action :set_contact

    def create
      interaction = Interaction.new(params.require(:interaction).permit(:kind, :occurred_at, :body))
      interaction.occurred_at ||= Time.current
      others = params.dig(:interaction, :other_emails).to_s.split(/[,;\s]+/).filter_map { |address| Contact.find_by_email(address) }.uniq

      if interaction.valid?
        interaction.record!([ @contact, *others ])
        ([ @contact ] + others.to_a).each(&:refresh_last_entry!)
        redirect_to @contact, notice: "#{interaction.kind.humanize} logged."
      else
        redirect_to @contact, alert: interaction.errors.full_messages.to_sentence
      end
    end
  end
end
