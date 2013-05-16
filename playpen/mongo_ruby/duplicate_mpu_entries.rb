#!/usr/bin/env ruby

# This script will grab the first MPU entry, then create a 100 checkins back each hour from this date.
require 'active_support/all'
require 'json'
require 'mongo'
require 'time'
include Mongo

client = MongoClient.new('localhost', 27017)
db     = client['checkin_service']
coll   = db['marketing_product_usage']

item = coll.find_one()
#puts JSON.pretty_generate(item)

(1..100).each do |count|
	new_item = item.clone()
	new_item.delete("_id") 
	new_item["updated"] = item["updated"] - count.hours 
	new_item["created"] = item["created"] - count.hours
	new_item["date"] = item["date"] - count.hours
	begin
		coll.insert(new_item)
	rescue => e 
		puts "Ignorning exception: #{e}"
	end
end

puts "#{coll.find().count()} items in #{coll.name}"
