module Rapport
  class Sweep
    class Subscriptions < Base
      def call
        subscriptions = host(:subscription_class) or return

        subscriptions.includes(:customer).find_each do |subscription|
          account = account_for_customer(subscription.customer) or next

          contacts_for_account(account).find_each do |contact|
            # One row per status the Sweep has seen, dated when it was first seen.
            record(contact, kind: "subscription", occurred_at: status_seen_at(subscription),
                            title: "Subscription #{subscription.status.to_s.humanize.downcase}: #{subscription.name}",
                            payload: payload_for(subscription),
                            source: [ TimelineEntry.source_type_for(subscription), "#{subscription.id}:#{subscription.status}" ])

            if subscription.ends_at.present?
              record(contact, kind: "subscription_ended", occurred_at: subscription.ends_at,
                              title: "Subscription ended: #{subscription.name}",
                              payload: payload_for(subscription), source: [ TimelineEntry.source_type_for(subscription), "#{subscription.id}:ended" ])
            end
          end
        end
      end

      private

      # The first status is dated from creation; later ones from the last
      # update, which is the closest thing Pay keeps to a transition time.
      def status_seen_at(subscription)
        subscription.status == "trialing" || subscription.updated_at.nil? ? subscription.created_at : subscription.updated_at
      end

      def payload_for(subscription)
        {
          status: subscription.status,
          plan: subscription.processor_plan,
          name: subscription.name,
          trial_ends_at: subscription.trial_ends_at,
          ends_at: subscription.ends_at
        }
      end
    end
  end
end
