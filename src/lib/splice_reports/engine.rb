
module SpliceReports
  class Engine < ::Rails::Engine


    config.to_prepare do
      User.send :include, SpliceReports::UserExtensions
    end

    initializer :finisher_hook do |engine|
      require "#{File.dirname(__FILE__)}/../../app/models/splice_reports" 

      resources = Dir[File.dirname(__FILE__) + '/navigation/*.rb']
      resources.uniq.each{ |f| require f }
 
      ::Navigation::Additions.insert_after(:organizations, SpliceReports::Navigation::ReportFilter)
    end
  end
end
