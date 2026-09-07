require_relative "lib/rapport/version"

Gem::Specification.new do |spec|
  spec.name        = "rapport"
  spec.version     = Rapport::VERSION
  spec.authors     = [ "Scott Harvey" ]
  spec.email       = [ "hello@example.com" ]
  spec.summary     = "Operator-only relationship tracking for a Rails app's prospects and customers."
  spec.description = "Rapport keeps a Contact for every person the operator cares about and merges everything the host app knows about them into one Timeline."
  spec.license     = "MIT"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.0"
end
