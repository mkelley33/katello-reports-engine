#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.


module SpliceReports
  class Engine < ::Rails::Engine

    config.to_prepare do
      User.send :include, SpliceReports::UserExtensions
    end

    initializer "splice_reports.load_app_instance_data" do |app|
        app.config.paths['db/migrate'] += SpliceReports::Engine.paths['db/migrate'].existent
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
      begin
        SpliceReports::Engine.load_seed()
      rescue  => e
        puts "SpliceReports Unable to load seed data"
        puts e.message
        puts e.backtrace
      end
    end
  end
end
