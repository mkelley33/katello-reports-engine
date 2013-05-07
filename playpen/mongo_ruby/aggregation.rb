#!/usr/bin/ruby
require 'mongo'

include Mongo

@client = MongoClient.new('localhost', 27017)
@db     = @client['results']
@coll   = @db['marketing_report_data']

#puts coll.aggregate([
#  {"$group" => {_id: "$state", total_pop: {"$sum" => "$pop"}}},
#  {"$match" => {total_pop: {"$gte" => 10_000_000}}}
#])

puts @coll.aggregate([
	{"$match" => { status: "current"}},
	{"$group" => {
	  _id: "$systemid",
	  date: {"$max" => "$created"},
	  status: {"$addToSet" => "$status"},
	  systemid: {"$addToSet" => "$_id"},
	  satellite: {"$addToSet" => "$splice_server"}
		}
	 },
	{"$sort" => {status: 1}},
		
])

puts @coll.aggregate([
	{"$match" => { "$or" => [{ status: "invalid"}, { status: "insufficient"}] }},
	{"$group" => {
	  _id: "$systemid",
	  date: {"$max" => "$created"},
	  status: {"$addToSet" => "$status"},
	  systemid: {"$addToSet" => "$_id"},
	  satellite: {"$addToSet" => "$splice_server"}
		}
	 },
	{"$sort" => {status: 1}},
		
])