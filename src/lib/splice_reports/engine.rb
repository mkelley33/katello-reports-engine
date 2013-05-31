
module SpliceReports
  class Engine < ::Rails::Engine

    config.to_prepare do
      User.send :include, SpliceReports::UserExtensions
    end
    
    initializer "splice_reports.assets.precompile", :group => :all do |app|
      app.config.assets.precompile << SpliceReports::Engine.root.join('app', 'assets', 'javascripts')
      app.config.assets.precompile << SpliceReports::Engine.root.join('app', 'assets', 'stylesheets')
    end

    initializer :finisher_hook do |engine|
      require "#{File.dirname(__FILE__)}/../../app/models/splice_reports" 

      resources = Dir[File.dirname(__FILE__) + '/navigation/*.rb']
      resources.uniq.each{ |f| require f }
 
      ::Navigation::Additions.insert_after(:organizations, SpliceReports::Navigation::ReportFilter)
      begin
        SpliceReports::Configuration.load()
      rescue => e 
        puts "Unable to load SpliceReports Configuration"
        puts e.message
        puts e.backtrace
      end
    end
  end
end
