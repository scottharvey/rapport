module Rapport
  class RemindersController < ApplicationController
    before_action :set_contact

    def update
      cadence = params[:reminder_cadence_days].presence
      if @contact.update(reminder_cadence_days: cadence)
        redirect_to @contact, notice: cadence ? "Reminder set to every #{cadence} days." : "Reminder cleared."
      else
        redirect_to @contact, alert: @contact.errors.full_messages.to_sentence
      end
    end
  end
end
