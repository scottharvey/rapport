module Rapport
  class CustomFieldsController < ApplicationController
    before_action :set_contact

    # Adds or replaces one key; a blank value removes it.
    def update
      key = params[:key].to_s.strip
      value = params[:value].to_s.strip
      fields = @contact.custom_fields.dup
      if key.blank?
        return redirect_to @contact, alert: "Field name can't be blank."
      elsif value.blank?
        fields.delete(key)
      else
        fields[key] = value
      end
      @contact.update!(custom_fields: fields)
      redirect_to @contact, notice: "Custom fields updated."
    end
  end
end
