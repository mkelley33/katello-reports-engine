#run from rvm

# execute
require 'mongo'
require 'pp'
require 'pry'
require 'pry-nav'

require_relative './filter'
require_relative './mongo_conn'
require_relative '../../src/lib/splice_reports/report_query'

include SpliceReports



	class Start
	  include Mongo

      def initialize
      	conn = MongoConn.new()
      	@marketing_report_data = conn.get_coll_marketing_report_data()

      end

      def get_collection
      	return @marketing_report_data
      end

      #def count
      #	puts "from run_me"
      #	puts @marketing_report_data.count()
      #end
    end

#test connection
test = Start.new()
coll = test.get_collection()
puts coll.count()


#test query module
q = ReportQuery.new(test.get_collection)
params = {}

#execute a filter: 

#create filter
	#@name = name
	#@hours = hours #nil
	#@start_date = start_date #"2013-05-01 04:00:00"
	#@end_date = end_date #"2013-06-30 04:00:00"
	#@status = status #["Current", "Invalid", "Insufficient"]
	#@inactive = inactive #false
	#@organizations = []
#def get_marketing_product_results(filter, params, offset, search, page_size)
page_size = 25

f = Filter.new("test1", nil, "2013-05-01", "2013-06-30", ["Current", "Invalid", "Insufficient"], false)
result =  q.get_marketing_product_results(f, params, nil, nil, page_size)
puts result
puts result.count
puts "==" * 20

f = Filter.new("test1", nil, "2013-05-01", "2013-06-30", ["Current"], false)
result =  q.get_marketing_product_results(f, params, nil, nil, page_size)
puts result
puts result.count
puts "==" * 20

f = Filter.new("test1", nil, "2013-05-01", "2013-06-30", ["Invalid"], false)
result =  q.get_marketing_product_results(f, params, nil, nil, page_size)
puts result
puts result.count
puts "==" * 20

f = Filter.new("test1", nil, "2013-05-01", "2013-06-30", ["Insufficient"], false)
result =  q.get_marketing_product_results(f, params, nil, nil, page_size)
puts result
puts result.count
puts "==" * 20








