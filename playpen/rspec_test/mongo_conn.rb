#
require 'mongo'

  class MongoConn

    include Mongo

    def initialize
      @client = MongoClient.new('localhost', 27017)
    end

    def get_coll_marketing_report_data
      @results = @client['checkin_service']
      @marketing_report_data   = @results['marketing_product_usage']
      return @marketing_report_data
    end
end

