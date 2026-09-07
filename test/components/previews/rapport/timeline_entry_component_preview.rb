module Rapport
  class TimelineEntryComponentPreview < ViewComponent::Preview
    # One entry per kind, with realistic titles and details
    def kinds
      render_with_template(locals: { entries: sample_entries })
    end

    private

    def sample_entries
      now = Time.current
      [
        [ "note", "Prefers email over calls", { "body" => "Prefers email over calls. Based in Perth, so mornings AWST." } ],
        [ "interaction", "Call: discussed Pro rollout", { "interaction_kind" => "call", "body" => "Discussed Pro rollout across three apps." } ],
        [ "touched", "Marked as touched", {} ],
        [ "email", "Email: Welcome to Rails Pulse", { "mailer" => "UserMailer" } ],
        [ "chat", "Livechat: Do you support Rails 8?", { "page_url" => "https://example.com/pricing" } ],
        [ "charge", "Paid $49.00", { "amount" => 4900, "currency" => "usd" } ],
        [ "subscription", "Subscription trialing: Rails Pulse Pro", { "plan" => "price_pro", "trial_ends_at" => (now + 14.days).iso8601 } ],
        [ "subscription_ended", "Subscription ended: Rails Pulse Pro", {} ],
        [ "event", "registered", {} ],
        [ "testimonial", "Testimonial (approved): Saved us hours every week", { "body" => "Saved us hours every week." } ],
        [ "nps", "NPS 9", { "score" => 9, "comment" => "Would recommend." } ],
        [ "feedback", "Feedback (bug): Chart tooltip overlaps", { "page_url" => "https://example.com/dashboard" } ],
        [ "user_deleted", "User deleted", {} ]
      ].each_with_index.map do |(kind, title, payload), i|
        Rapport::TimelineEntry.new(kind:, title:, payload:, occurred_at: now - i.hours, status: kind == "email" ? "sent" : nil,
                                   source_type: "Preview", source_id: i.to_s)
      end
    end
  end
end
