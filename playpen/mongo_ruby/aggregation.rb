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
	{"$match" => {created: {"$gt" => Time.utc(2013, 01, 05), "$lt" => Time.utc(2013, 03, 07)}}},
	{"$match" => { status: "current"}},
	{"$group" => {
	  _id: "$record_identifier",
	  date: {"$max" => "$created"},
	  status: {"$last" => "$status"},
	  identifier: {"$last" => "$instance_identifier"},
	  satellite: {"$last" => "$splice_server"},
	  systemid: {"$last" => "$systemid"}
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

a = result4.to_json
puts a
