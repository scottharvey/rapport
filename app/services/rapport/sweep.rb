module Rapport
  # The only way host data enters Rapport. Runs every Source in a fixed order,
  # then recomputes Stage. Each step is isolated so one failing source does not
  # stop the rest. Idempotent: every write is a find-or-create or an upsert.
  class Sweep
    SOURCES = [
      Sweep::Users,
      Sweep::Accounts,
      Sweep::Subscriptions,
      Sweep::Charges,
      Sweep::AhoyEvents,
      Sweep::LivechatConversations,
      Sweep::Testimonials,
      Sweep::NpsResponses,
      Sweep::Feedback
    ].freeze

    def self.call
      new.call
    end

    def call
      SOURCES.each { |source| run(source) }
      run(Sweep::DeletedUsers)
      run(Sweep::Stages)
      run(Sweep::LastEntries)
      self
    end

    private

    def run(source)
      source.new.call
    rescue StandardError => e
      Rails.logger.error("[Rapport::Sweep] #{source.name} failed: #{e.class}: #{e.message}")
      raise if Rails.env.test?
    end
  end
end
