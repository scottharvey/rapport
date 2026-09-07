module Rapport
  class InteractionParticipant < ApplicationRecord
    belongs_to :interaction
    belongs_to :contact
  end
end
