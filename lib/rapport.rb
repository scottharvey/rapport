require "rapport/version"
require "rapport/entry_links"
require "rapport/configuration"
require "rapport/engine"

module Rapport
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    # Resolves a configured host class name. Returns nil when the host does not
    # have that class (an engine not installed, for instance) so sources can skip.
    def host_class(name)
      configuration.public_send(name).to_s.safe_constantize
    end
  end
end
