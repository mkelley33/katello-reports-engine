# execute
require 'mongo'
require 'pp'
require 'pry'
require 'pry-nav'

require_relative './query'
require_relative './filter'

	class Start
	  include Mongo

      def initialize
      	@client = MongoClient.new('localhost', 27017)
      	@results = @client['checkin_service']
      	@marketing_report_data   = @results['marketing_product_usage']
      end

      def get_collection()
      	return @marketing_report_data
      end

      def count
      	puts "from run_me"
      	puts @marketing_report_data.count()
      end
    end

#test connection
test = Start.new()
#test.count

#test query module
q = Query.new(test.get_collection)
#puts q.count()

#test filter
f = Filter.new("test1")
#puts f.name, f.start_date
#puts f.organizations[0].id
#puts f.status

#test aggregation
#get_marketing_product_results(filter, offset, search)
params = {}
puts q.get_marketing_product_results(f, params, nil, nil)







