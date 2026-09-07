module Rapport
  class EmailAddress < ApplicationRecord
    belongs_to :contact

    normalizes :address, with: ->(a) { normalize_address(a) }

    validates :address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

    after_create :attach_company_by_domain


    def self.normalize_address(address)
      address.to_s.strip.downcase
    end

    def domain
      address.split("@").last
    end

    private

    # A Contact with no Company joins the one whose domain matches.
    def attach_company_by_domain
      return if contact.company_id.present?

      company = Company.for_domain(domain) or return
      contact.update_column(:company_id, company.id)
    end
  end
end
