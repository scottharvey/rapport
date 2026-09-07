module Rapport
  class SweepJob < ActiveJob::Base
    queue_as :default

    def perform
      Sweep.call
    end
  end
end
