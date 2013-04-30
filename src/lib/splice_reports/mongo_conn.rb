require 'mongo'
module SpliceReports

  class MongoConn

    include Mongo

    def initialize
      @client = MongoClient.new('localhost', 27017)
      @db     = @client['results']
      @coll   = @db['marketing_report_data']

    end

    def get_collection
      return @coll
    end
  end
end
