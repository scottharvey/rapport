module Rapport
  class TimelineEntriesController < ApplicationController
    before_action :set_contact

    def destroy
      entry = @contact.timeline_entries.find(params[:id])
      return redirect_to @contact, alert: "Only notes, interactions and touches can be removed." unless entry.deletable?

      Contact.transaction do
        case entry.kind
        when "note" then Note.find_by(id: entry.source_id)&.destroy!
        when "interaction" then leave_interaction(entry)
        end
        entry.destroy! if entry.persisted?
        @contact.recompute_last_touch!
        @contact.refresh_last_entry!
      end
      redirect_to @contact, notice: "Removed from the timeline."
    end

    private

    # This Contact drops out of the Interaction; it is destroyed once nobody is left.
    def leave_interaction(entry)
      interaction = Interaction.find_by(id: entry.source_id) or return
      interaction.interaction_participants.where(contact_id: @contact.id).destroy_all
      interaction.destroy! if interaction.interaction_participants.none?
    end
  end
end
