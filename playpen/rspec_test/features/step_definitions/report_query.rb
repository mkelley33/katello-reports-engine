#unique instances
require 'date'

require_relative '../../mongo_conn'
require_relative '../../filter'
require_relative '../../../../src/lib/splice_reports/report_query'

#setup the db
db = MongoConn.new()
mpu = db.get_coll_marketing_report_data()

Given(/^there is a populated database with one instance where the last checkin is Current "(.*?)"$/) do |arg1|
  mpu.drop()
  load_db = system("mongorestore data/dump")
  load_db.should == true
  arg1.to_i.should == mpu.distinct('instance_identifier').count
end

When(/^I define a filter "(.*?)" starting at "(.*?)" ending at "(.*?)" with entitlement_status "(.*?)" and inactive "(.*?)"$/) do |name, f_start, f_end, status, inactive|
#When(/^I define a filter "(.*?)"$/) do |name, start|
#
  @filter = Filter.new(name, nil, f_start, f_end, status.split(","), inactive)
#
end

Then(/^when I execute the filter, the report should have this number of rows "(.*?)"$/) do |arg1|
  @result = 0
  params = {}
  q = ReportQuery.new(mpu)
  #result =  q.get_marketing_product_results(f, params, nil, nil, page_size)
  @result =  q.get_marketing_product_results(@filter, params, nil, nil, 25)
  @result.count.to_s.should == arg1
end

##################

Given(/^there is a populated database with three instances each with a different status "(.*?)"$/) do |arg1|
  create_checkins = system("../create_sample_data/create.py -u #{arg1} -p ../create_sample_data/")
  create_checkins.should == true
  load_db = system("../create_sample_data/load_data.py -d -p ../create_sample_data/")
  load_db.should == true
end

When(/^I define a filter called each_status "(.*?)" starting at "(.*?)" ending at "(.*?)" with entitlement_status "(.*?)" and inactive "(.*?)"$/) do |name, f_start, f_end, status, inactive|
  #double check that yesterday and tomorrow were passed in.
  f_start.should == "yesterday"
  f_end.should == "tomorrow"
  
  today = DateTime.now
  yesterday = today - 1
  tomorrow = today + 1
  inactive = false if inactive == "false"
  inactive = true if inactive == "true"
  @filter = Filter.new(name, nil, yesterday.to_time, tomorrow.to_time, status.split(","), inactive)
end

Then(/^when I execute each_status, the report should have this number of rows "(.*?)"$/) do |arg1|
  @result = 0
  params = {}
  q = ReportQuery.new(mpu)
  #result =  q.get_marketing_product_results(f, params, nil, nil, page_size)
  @result =  q.get_marketing_product_results(@filter, params, nil, nil, 25)
  @result.count.to_s.should == arg1

end





