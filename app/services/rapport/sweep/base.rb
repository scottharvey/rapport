module Rapport
  class Sweep
    class Base
      private

      def host(name)
        Rapport.host_class(name)
      end

      # Finds a Contact by any of its addresses, or creates one as a lead.
      def contact_for_email(address, source:, name: nil)
        contact = Contact.find_by_email(address)
        return contact if contact

        return nil if address.blank? || !address.to_s.match?(URI::MailTo::EMAIL_REGEXP)

        Contact.transaction do
          contact = Contact.create!(name: name.presence, source: source)
          contact.add_email(address, primary: true)
          contact
        end
      end

      def record(contact, **attrs)
        TimelineEntry.record!(contact:, **attrs)
      end

      # Every Contact linked to a User who belongs to the Account.
      def contacts_for_account(account)
        return Contact.none unless account.respond_to?(:users)

        Contact.where(user_id: account.users.pluck(:id))
      end

      # Pay customers hang off the Account (the owner). Anything else is skipped.
      def account_for_customer(customer)
        account_class = host(:account_class) or return nil
        owner = customer&.owner
        owner if owner.is_a?(account_class)
      end

      def money(amount_cents, currency)
        format("%s%.2f", currency.to_s.casecmp?("usd") ? "$" : "#{currency.to_s.upcase} ", amount_cents.to_i / 100.0)
      end
    end
  end
end
