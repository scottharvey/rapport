module Rapport
  # The Contact page composer: one form that writes a Note or logs an
  # Interaction depending on the kind picked.
  class EntriesController < ApplicationController
    before_action :set_contact

    def create
      kind = entry_params[:kind].to_s
      if kind == "note"
        create_note
      elsif Interaction::KINDS.include?(kind)
        create_interaction(kind)
      else
        redirect_to @contact, alert: "Pick what kind of entry this is."
      end
    end

    private

    def entry_params
      params.require(:entry).permit(:kind, :body, :occurred_at, :other_emails)
    end

    def create_note
      note = @contact.notes.build(body: entry_params[:body])
      if note.save
        @contact.refresh_last_entry!
        redirect_to @contact, notice: "Note added."
      else
        redirect_to @contact, alert: "Write something first."
      end
    end

    def create_interaction(kind)
      interaction = Interaction.new(kind: kind, body: entry_params[:body], occurred_at: entry_params[:occurred_at].presence || Time.current)
      others = entry_params[:other_emails].to_s.split(/[,;\s]+/).filter_map { |address| Contact.find_by_email(address) }.uniq - [ @contact ]
      if interaction.valid?
        interaction.record!([ @contact, *others ])
        ([ @contact ] + others).each(&:refresh_last_entry!)
        redirect_to @contact, notice: "#{kind.humanize} logged#{" with #{others.map(&:display_name).to_sentence}" if others.any?}."
      else
        redirect_to @contact, alert: interaction.errors.full_messages.to_sentence
      end
    end
  end
end
