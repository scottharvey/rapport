module Rapport
  class Sweep
    class Stages < Base
      def call
        Contact.find_each do |contact|
          stage = Stage.derive(contact)
          contact.update_column(:stage, stage) if contact.stage != stage
        end
      end
    end
  end
end
