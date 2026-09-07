module Rapport
  class Sweep
    class Users < Base
      def call
        users = host(:user_class) or return

        users.find_each do |user|
          contact = Contact.find_by(user_id: user.id) || Contact.find_by_email(user.email_address)
          contact ||= Contact.create!(source: "signup")

          contact.user_id = user.id
          contact.avatar_url = user.avatar_url if user.respond_to?(:avatar_url) && user.avatar_url.present?
          contact.save! if contact.changed?
          contact.add_email(user.email_address, primary: contact.email_addresses.none?)
        end
      end
    end
  end
end
