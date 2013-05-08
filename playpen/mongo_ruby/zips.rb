#!/usr/bin/ruby
require "mongo"
include Mongo

db = MongoClient.new("localhost", 27017, w: 1).db("test")
coll = db.collection("zipcodes")
coll.count     #=> should return 29467
puts coll.find_one

puts coll.aggregate([
  {"$group" => {_id: "$state", total_pop: {"$sum" => "$pop"}}},
  {"$match" => {total_pop: {"$gte" => 10_000_000}}}
])

puts coll.aggregate([
  {"$group" => {_id: {state: "$state", city: "$city"}, pop: {"$sum" => "$pop"}}},
  {"$sort" => {pop: 1}},
  {"$group" => {
                _id: "$_id.state",
      smallest_city: {"$first" => "$_id.city"},
       smallest_pop: {"$first" => "$pop"},
       biggest_city: { "$last" => "$_id.city"},
        biggest_pop: { "$last" => "$pop"}
    }
  }
])