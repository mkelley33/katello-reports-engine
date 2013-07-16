$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "splice_reports/version"


# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "splice_reports"
  s.version     = SpliceReports::VERSION
  s.authors     = ["Wes Hayutin", "Justin Sherril", "John Matthews"]
  s.email       = ["whayutin@redhat.com", "jsherril@redhat.com", "jmatthews@redhat.com", "splice-devel@redhat.com"]
  s.homepage    = "https://github.com/splice/splice-reports"
  s.summary     = "Rails engine to provide enhanced reports for Katello/SAM."
  s.description = "Description of SpliceReports."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  # s.add_dependency "jquery-rails"
  s.add_dependency "mongo"
  s.add_dependency "bson_ext"
  s.add_dependency "zipruby"


  s.add_dependency "rails", "~> 3.2"
  s.add_development_dependency "sqlite3"

end
