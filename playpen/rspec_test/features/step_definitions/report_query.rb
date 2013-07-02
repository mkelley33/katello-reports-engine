#unique instances

require_relative '../../mongo_conn'
require_relative '../../filter'
require_relative '../../../../src/lib/splice_reports/report_query'

#setup the db
db = MongoConn.new()
mpu = db.get_coll_marketing_report_data()

Given(/^there is one unique instance in the db  "(.*?)"$/) do |arg1|

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


