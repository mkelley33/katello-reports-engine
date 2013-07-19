#!/usr/bin/ruby
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


print "Find objects w/ invalid status using NOT: "  
status = @coll.find({"entitlement_status.status" => { "$ne" => "valid"}}, :fields => ["entitlement_status.status"]).to_a
print status.to_s << space

print "Find objects NOT in a date range:"
date_range = @coll.find({"created" => { "$not" => {"$gt" => Time.utc(2013, 05, 12)}}}, :fields => ["created"]).to_a
print date_range.to_s << space


print "FIND and SORT\n"
#results = @coll.find({ "instance_identifier" => "28f4cbcb-c503-4d20-a725-333eb1e36142" },  :fields => ["instance_identifier"]).to_a
#results = @coll.find.sort({ "instance_identifier" => "28f4cbcb-c503-4d20-a725-333eb1e36142" }, :limit => 1, :fields => ["instance_identifier"]).to_a
print "ASCENDING\n"
results = @coll.find({"instance_identifier" => "1735fd13-c694-4175-8302-ec5c98b1a4e0"}, {:skip => 0, :limit => 2, :sort => ['checkin_date', Mongo::ASCENDING]}).to_a
results.map do |item|
  print item.to_s << space
end
print "DECENDING\n"
results = @coll.find({"instance_identifier" => "1735fd13-c694-4175-8302-ec5c98b1a4e0"}, {:skip => 0, :limit => 2, :sort => ['checkin_date', Mongo::DESCENDING]}).to_a
results.map do |item|
  print item.to_s << space
end
	




