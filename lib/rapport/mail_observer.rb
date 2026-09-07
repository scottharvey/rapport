module Rapport
  # Registered with ActionMailer at boot. Every delivered message becomes an
  # email Timeline entry on each recipient Contact. The status and message id
  # are stored so delivery webhooks can update them later.
  class MailObserver
    def self.delivered_email(message)
      recipients = Array(message.to) + Array(message.cc) + Array(message.bcc)
      recipients.uniq.each do |address|
        contact = Contact.find_by_email(address) or next
        TimelineEntry.record!(
          contact: contact,
          kind: "email",
          occurred_at: message.date&.to_time || Time.current,
          title: "Email: #{message.subject}",
          payload: { mailer: mailer_name(message), subject: message.subject, to: address },
          source: [ "ActionMailer", message.message_id.presence || "#{address}:#{Time.current.to_f}" ],
          status: "sent"
        )
        contact.refresh_last_entry!
      end
    rescue StandardError => e
      Rails.logger.warn("[Rapport::MailObserver] #{e.class}: #{e.message}")
      raise if Rails.env.test?
    end

    def self.mailer_name(message)
      handler = message.delivery_handler
      handler.respond_to?(:name) ? handler.name : handler.class.name
    end
  end
end
