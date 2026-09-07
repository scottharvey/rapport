module Rapport
  class EmailAddressesController < ApplicationController
    before_action :set_contact

    def create
      address = params[:new_address].to_s
      if Contact.find_by_email(address)
        redirect_to @contact, alert: "That address already belongs to a @contact."
      elsif @contact.add_email(address, primary: params[:primary].present?)
        redirect_to @contact, notice: "Email address added."
      else
        redirect_to @contact, alert: "Enter a valid email address."
      end
    rescue ActiveRecord::RecordInvalid => e
      redirect_to @contact, alert: e.message
    end
  end
end
