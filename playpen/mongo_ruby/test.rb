#!/usr/bin/ruby
require 'rubygems'
require 'mongo'

include Mongo

@client = MongoClient.new('localhost', 27017)
@db     = @client['checkin_service']
@coll   = @db['marketing_product_usage']

space = "\n"*2
space

print "Print one object" << space
one = @coll.find_one
print one.to_s << space

print "Total number of objects in DB: " << @coll.count.to_s << space

print "Find objects by date range:"
date_range = @coll.find({"date" => {"$gt" => Time.utc(2013, 05, 12), "$lt" => Time.utc(2013, 05, 14)}}, :fields => ["date"]).to_a
print date_range.to_s << space

print "Find objects by date range and status:"
date_range = @coll.find({"date" => {"$gt" => Time.utc(2013, 05, 12), "$lt" => Time.utc(2013, 05, 14)}, "status" => "partial"}, :fields => ["date", "status"]).to_a
print date_range.to_s << space

print "Find objects by id: "
by_id = @coll.find({"_id" => BSON::ObjectId('5165c848421aa99a4e00000a')}, :fields => ["_id"]).to_a
print by_id.to_s << space

print "Find objects w/ invalid status: "  
status = @coll.find({"entitlement_status.status" => "valid"}, :fields => ["entitlement_status.status"]).to_a
print status.to_s << space

print "Get a list of all systems \n"
systems_unique = @coll.distinct("instance_identifier").to_a
print systems_unique.to_s
print "\n"
start_date = Time.utc(2013, 04, 12)
end_date = Time.utc(2013, 05, 30)
list = Hash.new
systems_unique.each do |system|
  row = @coll.find({"instance_identifier" => system,
  					"created" => {"$gt" => start_date, "$lt" => end_date}},
  				 :fields => ["created"],
  				 :sort => ['created', :asc]).limit(1).to_a
  #print row[0]["created"].to_s
  list[system]=row[0]["created"].to_s
end
print "list of keys \n"
print list.keys
print (systems_unique -  list.keys).to_s << space


print "Find objects w/ invalid status using NOT: "  
status = @coll.find({"entitlement_status.status" => { "$ne" => "valid"}}, :fields => ["entitlement_status.status"]).to_a
print status.to_s << space

print "Find objects NOT in a date range:"
date_range = @coll.find({"created" => { "$not" => {"$gt" => Time.utc(2013, 05, 12)}}}, :fields => ["created"]).to_a
print date_range.to_s << space

	




