
module SpliceReports
  class Engine < ::Rails::Engine

    initializer :finisher_hook do |engine|

      require "#{File.dirname(__FILE__)}/../../app/models/splice_reports" 
      #resources = Dir[File.dirname(__FILE__) + '/navigation/*.rb']
      #resources.uniq.each{ |f| require f }
 
      #::Experimental::Navigation::Additions.insert_after(:import_history, Foo::Navigation::ReportFilter)
    end
  end
end
