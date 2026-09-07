module Rapport
  class Sweep
    # Feedback carries no email, only the host user id as a string and a label.
    class Feedback < Base
      def call
        feedbacks = host(:feedback_class) or return

        feedbacks.find_each do |feedback|
          contact = contact_for(feedback) or next
          record(contact, kind: "feedback", occurred_at: feedback.created_at,
                          title: "Feedback (#{feedback.kind}): #{feedback.message.to_s.truncate(80)}",
                          payload: { kind: feedback.kind, status: feedback.status, message: feedback.message, page_url: feedback.page_url },
                          source: feedback)
        end
      end

      private

      def contact_for(feedback)
        if feedback.author_id.to_s.match?(/\A\d+\z/)
          contact = Contact.find_by(user_id: feedback.author_id.to_i)
          return contact if contact
        end
        contact_for_email(feedback.author_label, source: "feedback")
      end
    end
  end
end
