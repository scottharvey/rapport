module Rapport
  class Sweep
    # A Contact outlives their User. The link is cleared, the Stage becomes
    # churned on the next derivation, and the deletion is on the Timeline.
    class DeletedUsers < Base
      def call
        users = host(:user_class) or return

        Contact.where.not(user_id: nil).find_each do |contact|
          next if users.exists?(id: contact.user_id)

          user_id = contact.user_id
          contact.update!(user_id: nil)
          record(contact, kind: "user_deleted", occurred_at: Time.current, title: "User deleted",
                          payload: { user_id: user_id }, source: [ users.name, "#{user_id}:deleted" ])
        end
      end
    end
  end
end
