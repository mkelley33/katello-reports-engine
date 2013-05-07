#!/usr/bin/ruby
require 'mongo'
require 'json'

include Mongo

@client = MongoClient.new('localhost', 27017)
@db     = @client['results']
@coll   = @db['marketing_report_data']

#puts coll.aggregate([
#  {"$group" => {_id: "$state", total_pop: {"$sum" => "$pop"}}},
#  {"$match" => {total_pop: {"$gte" => 10_000_000}}}
#])

result1 = @coll.aggregate([
	{"$match" => { status: "current"}},
	{"$group" => {
	  _id: "$instance_identifier",
	  date: {"$max" => "$created"},
	  status: {"$addToSet" => "$status", },
	  identifier: {"$addToSet" => "$instance_identifier"},
	  satellite: {"$addToSet" => "$splice_server"}
		}
	 },
	{"$sort" => {status: 1}},
		
])

result2 = @coll.aggregate([
	#{"$match" => { "$or" => [{ status: "invalid"}, { status: "insufficient"}] }},

	{"$group" => {
	  _id: "$instance_identifier",
	  date: {"$max" => "$created"},
	  status: {"$last" => "$status"},
	  identifier: {"$addToSet" => "$instance_identifier"},
	  satellite: {"$addToSet" => "$splice_server"},
	  systemid: {"$addToSet" => "$systemid"}
		}
	 },
	{"$sort" => {status: 1}},
	{"$project" => {status: 1, systemid: 1 }}
	
		
])

a = result2.to_json
puts a
