#fake filter object

#<SpliceReports::Filter id: 4, name: "asdf", description: "asdf", locked: false, hours: nil,
# satellite_name: "ec2-50-19-34-184.compute-1.amazonaws.com", start_date: "2013-05-01 04:00:00",
# end_date: "2013-06-30 04:00:00", status: ["Current", "Invalid", "Insufficient"], 
#created_at: "2013-06-10 21:13:09", updated_at: "2013-06-10 21:14:35", user_id: 1, inactive: false> 

#SpliceReports::Filter.find(4).organizations
#= "splice_reports_filters_organizations"."organization_id" 
#WHERE "splice_reports_filters_organizations"."splice_reports_filter_id" = 4

# => [#<Organization id: 1, name: "ACME_Corporation", description: "ACME_Corporation Organization", label: "ACME_Corporation",
# created_at: "2013-06-10 20:28:12", updated_at: "2013-06-10 20:28:12", deletion_task_id: nil, 
#default_info: {"system"=>[], "distributor"=>[]}, apply_info_task_id: nil>, #<Organization id: 2, 
#name: "org1", description: "asdf", label: "org1", created_at: "2013-06-10 21:13:54", updated_at: "2013-06-10 21:13:54", 
#deletion_task_id: nil, default_info: {"system"=>[], "distributor"=>[]}, apply_info_task_id: nil>, #<Organization id: 3, 
#name: "org2", description: "asdf", label: "org2", created_at: "2013-06-10 21:14:07", updated_at: "2013-06-10 21:14:07",
# deletion_task_id: nil, default_info: {"system"=>[], "distributor"=>[]}, apply_info_task_id: nil>] 

class Filter
  attr_accessor :name, :hours, :start_date, :end_date, :status, :inactive, :organizations

  def initialize(name)
  	@name = name
  	@description = name
  	@locked = false
  	@hours = nil
  	@satellite_name = 'any'
  	@start_date = "2013-05-01 04:00:00"
  	@end_date = "2013-06-30 04:00:00"
  	@status = ["Current", "Invalid", "Insufficient"]
  	@inactive = false
  	@organizations = []

  	
  	org1 = Organizations.new(1)
  	org2 = Organizations.new(2)
  	@organizations = [org1, org2]

  end

  def to_hash
    Hash[instance_variables.map { |var| [var[1..-1].to_s, instance_variable_get(var)] }]
  end

end

class Organizations
  attr_accessor :id

  def initialize(id)
  	@id = id
  end

end




