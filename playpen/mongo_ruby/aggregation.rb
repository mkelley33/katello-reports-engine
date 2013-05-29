#!/usr/bin/ruby
require 'mongo'
require 'json'

include Mongo

@client = MongoClient.new('localhost', 27017)
@db     = @client['checkin_service']
@coll   = @db['marketing_product_usage']

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

	#{"$match" => {created: {"$gt" => Time.utc(2013, 01, 05), "$lt" => Time.utc(2013, 06, 07)}}},
	#{"$match" => { "entitlement_status.status" => { "$in" => ["valid", "invalid", "parital"] }}},
	{"$match" => { "entitlement_status.status" => { "$in" => ["valid", "invalid", "partial"] }}},
	#{"$match" => { "entitlement_status.status" => "invalid"}},
	#{"$match" => { "organization_id" => { "$in" => ["3"]}}},
	{"$group" => {
	  _id: "$instance_identifier",
	  record: {"$last" => "$_id"},
	  date: {"$last" => "$created"},
	  status: {"$last" => "$entitlement_status.status"},
	  identifier: {"$last" => "$instance_identifier"},
	  satellite: {"$last" => "$splice_server"},
	  hostname: {"$last" => "$name"},
	  org: {"$last" => "$organization_id"},
	  systemid: {"$last" => "$facts.systemid"}
		}
	 },
	{"$sort" => {status: 1}},	
])

result3 = @coll.aggregate([
	{"$match" => { instance_identifier: "server_ident1"}},
	{"$group" => {
	  _id: "$record_identifier",
		}
	 },
	{"$sort" => {status: 1}},	
])

result4 = @coll.find({"instance_identifier" => "server_ident1"}, :fields => 
	["systemid", "status", "hostname", "environment", "created" ]).to_a


result5 = @coll.aggregate([
	#date_range = @coll.find({"date" => { "$not" => {"$gt" => Time.utc(2013, 05, 12), "$lt" => Time.utc(2013, 05, 14)}}}, :fields => ["date"]).to_a
	{"$match" => {"created" => { "$not" => {"$gt" => Time.utc(2013, 05, 14), "$lt" => Time.utc(2013, 05, 16)}}}},
	{"$group" => {
	  _id: "$instance_identifier",
	  record: {"$last" => "$_id"},
	  date: {"$max" => "$created"},
	  status: {"$last" => "$entitlement_status.status"},
	  identifier: {"$last" => "$instance_identifier"},
	  satellite: {"$last" => "$splice_server"},
	  hostname: {"$last" => "$name"},
	  systemid: {"$last" => "$facts.systemid"}
		}
	 },
	{"$sort" => {status: 1}},	
])

query = [

	{"$match" => {created: {"$gt" => Time.utc(2013, 01, 05), "$lt" => Time.utc(2013, 06, 07)}}},
	#{"$match" => { "entitlement_status.status" => { "$in" => ["valid", "invalid", "parital"] }}},
	{"$match" => { "entitlement_status.status" => "invalid"}},
	#{"$match" => { "organization_id" => { "$in" => ["3"]}}},
	{"$group" => {
	  _id: nil,
    count: {"$sum" => 1} 
		}
	 },
]

result6 = @coll.aggregate(query)
a = result6.to_a
puts a
