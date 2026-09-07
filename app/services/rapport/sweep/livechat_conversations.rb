module Rapport
  class Sweep
    class LivechatConversations < Base
      def call
        conversations = host(:livechat_conversation_class) or return

        conversations.where.not(visitor_email: [ nil, "" ]).find_each do |conversation|
          contact = contact_for_email(conversation.visitor_email, source: "livechat", name: conversation.visitor_label) or next
          record(contact, kind: "chat", occurred_at: conversation.created_at,
                          title: "Livechat (#{conversation.status})",
                          payload: { status: conversation.status, preview: conversation.last_message_preview, page_url: conversation.page_url },
                          source: conversation)
        end
      end
    end
  end
end
