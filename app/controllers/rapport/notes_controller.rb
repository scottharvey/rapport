module Rapport
  class NotesController < ApplicationController
    before_action :set_contact

    def create
      note = @contact.notes.build(params.require(:note).permit(:body))
      if note.save
        @contact.refresh_last_entry!
        redirect_to @contact, notice: "Note added."
      else
        redirect_to @contact, alert: "Note can't be blank."
      end
    end
  end
end
