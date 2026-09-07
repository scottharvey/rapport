module Rapport
  class Sweep
    class Users < Base
      def call
        users = host(:user_class) or return

        skip = Rapport.configuration.skip_user
        users.find_each do |user|
          if skip&.call(user)
            forget(user)
            next
          end

          contact = Contact.find_by(user_id: user.id) || Contact.find_by_email(user.email_address)
          contact ||= Contact.create!(source: "signup")

          contact.user_id = user.id
          contact.avatar_url = user.avatar_url if user.respond_to?(:avatar_url) && user.avatar_url.present?
          contact.save! if contact.changed?
          contact.add_email(user.email_address, primary: contact.email_addresses.none?)
        end
      end

      private

      # A skipped User's auto-created Contact is noise, but one the operator
      # has written on is kept and merely unlinked.
      def forget(user)
        contact = Contact.find_by(user_id: user.id) or return
        if contact.source == "signup" && contact.notes.none? && contact.interactions.none? && contact.reminder_cadence_days.nil?
          contact.destroy!
        else
          contact.update!(user_id: nil)
        end
      end
    end
  end
end
