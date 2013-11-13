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


require 'mongo'
module SpliceReports

  class MongoConn

    include Mongo

    def initialize
      reports_config = Katello.config.reports
      database_config = reports_config.database if reports_config
      if database_config
        host = database_config.host
        port = database_config.port
      end
      host ||= 'localhost'
      port ||= '27017'
      @client = MongoClient.new(host, port)
    end

    def get_coll_marketing_report_data
      @results = @client['checkin_service']
      @marketing_report_data   = @results['marketing_product_usage']
      return @marketing_report_data
    end

    def get_coll_pool
      @checkin_service = @client['checkin_service']
      @pool = @checkin_service['pool']
      return @pool
    end

    def get_coll_product
      @checkin_service = @client['checkin_service']
      @product = @checkin_service['product']
      return @product
    end

    def get_coll_splice_server
      @checkin_service = @client['checkin_service']
      @splice_server = @checkin_service['splice_server']
      return @splice_server
    end

    def get_splice_servers
      @checkin_service = @client['checkin_service']
      @splice_server = @checkin_service['splice_server']
      ss = @splice_server.find({"uuid" => /^./},:fields => ["uuid"]).to_a
      splice_servers = ss.collect{|s| s["uuid"]}
      return splice_servers
    end

  end
end
