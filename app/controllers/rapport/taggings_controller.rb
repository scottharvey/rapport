module Rapport
  class TaggingsController < ApplicationController
    before_action :set_contact

    def create
      name = params[:name].to_s.strip
      if name.present?
        @contact.taggings.find_or_create_by!(tag: Tag.named(name))
        redirect_to @contact, notice: "Tagged."
      else
        redirect_to @contact, alert: "Tag can't be blank."
      end
    end

    def destroy
      @contact.taggings.find(params[:id]).destroy!
      redirect_to @contact, notice: "Tag removed."
    end
  end
end
