require_relative "lib/rapport/version"

Gem::Specification.new do |spec|
  spec.name        = "rapport"
  spec.version     = Rapport::VERSION
  spec.authors     = [ "Scott Harvey" ]
  spec.email       = [ "scott@scottharvey.co" ]
  spec.homepage    = "https://github.com/scottharvey/rapport"
  spec.summary     = "Operator-only relationship tracking for a Rails app's prospects and customers."
  spec.description = "Rapport keeps a Contact for every person the operator cares about and merges everything the host app knows about them into one Timeline."
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "README.md", "CHANGELOG.md"]
  end

  spec.required_ruby_version = ">= 3.2"
  spec.add_dependency "rails", ">= 8.0"
end
