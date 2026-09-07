module Rapport
  class Sweep
    class Accounts < Base
      def call
        accounts = host(:account_class) or return

        accounts.find_each do |account|
          company = Company.find_or_initialize_by(account_id: account.id)
          company.name = account.name if company.new_record? || company.name.blank?
          company.source = "signup" if company.new_record?
          company.save! if company.changed?

          contacts_for_account(account).where(company_id: nil).update_all(company_id: company.id)
        end
      end
    end
  end
end
