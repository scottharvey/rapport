module Rapport
  class ContactsController < ApplicationController
    before_action :set_contact, only: %i[show edit update destroy touch merge]

    def index
      scope = Contact.includes(:company, :email_addresses, :tags)
      scope = scope.by_stage(params[:stage]) if Contact::STAGES.include?(params[:stage])
      scope = scope.with_tag(params[:tag]) if params[:tag].present?
      scope = scope.search(params[:q]) if params[:q].present?
      scope = params[:due].present? ? scope.due : scope.recent_first
      @pagy, @contacts = pagy(scope)
      @tags = Tag.order(:name)
      @due_count = Contact.due.count
    end

    def show
      @timeline_entries = @contact.timeline_entries.newest_first.limit(200)
      @tag_names = Tag.order(:name).pluck(:name)
      # [name, address] pairs for the merge and "also with" autocompletes.
      @address_options = EmailAddress.where.not(contact_id: @contact.id).includes(:contact).order(:address).limit(1000)
                                     .map { |email| [ email.contact.display_name, email.address ] }
    end

    def new
      @contact = Contact.new
    end

    def create
      @contact = Contact.new(contact_params.except(:address))
      @contact.source = "operator"
      @contact.email_addresses.build(address: contact_params[:address], primary: true)
      if @contact.save
        redirect_to @contact, notice: "Contact created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @contact.update(contact_params)
        redirect_to @contact, notice: "Contact updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @contact.destroy!
      redirect_to contacts_path, notice: "Contact deleted."
    end

    def touch
      @contact.touch!
      TimelineEntry.record!(contact: @contact, kind: "touched", occurred_at: @contact.last_touched_at, title: "Marked as touched",
                            source: [ "Rapport::Touch", @contact.last_touched_at.to_f.to_s ])
      @contact.refresh_last_entry!
      redirect_to @contact, notice: "Marked as touched."
    end

    def merge
      other = params[:other].present? ? Contact.find_by_email(params[:other]) : Contact.find_by(id: params[:other_id])
      if other.nil? || other == @contact
        redirect_to @contact, alert: "Pick a different contact to merge."
      else
        Merge.call(survivor: @contact, other: other)
        redirect_to @contact, notice: "Merged #{other.display_name} into #{@contact.display_name}."
      end
    end

    private

    def set_contact
      @contact = Contact.find(params[:id])
    end

    def contact_params
      params.require(:contact).permit(:name, :job_title, :phone, :avatar_url, :company_id, :manual_stage, :address)
    end
  end
end
