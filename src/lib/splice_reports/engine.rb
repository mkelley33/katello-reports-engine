module SpliceReports
  class Engine < ::Rails::Engine
    isolate_namespace SpliceReports

=begin
    initializer :finisher_hook do |engine|
     
      resources = Dir[File.dirname(__FILE__) + '/navigation/*.rb']
      resources.uniq.each{ |f| require f }
 
      ::Experimental::Navigation::Additions.insert_after(:import_history, Foo::Navigation::ReportFilter)
    end
=end
  end
end
