module Rapport
  class ApplicationController < Rapport.configuration.parent_controller.constantize
    layout Rapport.configuration.layout

    # The host's own guards redirect with host route helpers, which do not
    # resolve inside an isolated engine. Rapport authenticates on its own.
    Rapport.configuration.skip_host_before_actions.each do |name|
      skip_before_action name, raise: false
    end

    before_action :authenticate_rapport!

    private

    # For resources nested under a Contact.
    def set_contact
      @contact = Contact.find(params[:contact_id])
    end

    def authenticate_rapport!
      instance_exec(&Rapport.configuration.authenticate)
    end
  end
end
