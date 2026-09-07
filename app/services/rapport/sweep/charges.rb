module Rapport
  class Sweep
    class Charges < Base
      def call
        charges = host(:charge_class) or return

        charges.includes(:customer).find_each do |charge|
          account = account_for_customer(charge.customer) or next
          refunded = charge.amount_refunded.to_i

          contacts_for_account(account).find_each do |contact|
            title = "Paid #{money(charge.amount, charge.currency)}"
            title += " (refunded #{money(refunded, charge.currency)})" if refunded.positive?
            record(contact, kind: "charge", occurred_at: charge.created_at, title: title,
                            payload: { amount: charge.amount, amount_refunded: refunded, currency: charge.currency },
                            source: charge)
          end
        end
      end
    end
  end
end
