require 'mongo'
module SpliceReports

  class MongoConn

    include Mongo

    def initialize
      @client = MongoClient.new('localhost', 27017)


    end

    def get_coll_marketing_report_data
      @results = @client['results']
      @marketing_report_data   = @results['marketing_report_data']
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
      ss = @splice_server.find({"hostname" => /^./},:fields => ["hostname"]).to_a
      splice_servers = ss.collect{|s| s["hostname"]}
      return splice_servers
    end

  end
end
