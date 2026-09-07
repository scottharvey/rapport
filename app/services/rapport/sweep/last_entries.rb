module Rapport
  class Sweep
    # Caches each Contact's newest Timeline time so the index can sort on it.
    class LastEntries < Base
      def call
        Contact.find_each(&:refresh_last_entry!)
      end
    end
  end
end
