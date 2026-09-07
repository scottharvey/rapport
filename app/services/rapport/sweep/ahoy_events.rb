module Rapport
  class Sweep
    class AhoyEvents < Base
      def call
        events = host(:ahoy_event_class) or return

        events.where.not(user_id: nil).where.not("name LIKE '$%'").find_each do |event|
          contact = Contact.find_by(user_id: event.user_id) or next
          record(contact, kind: "event", occurred_at: event.time || event.created_at, title: event.name.to_s,
                          payload: { properties: event.properties || {} }, source: event)
        end
      end
    end
  end
end
