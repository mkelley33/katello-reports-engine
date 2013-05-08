module SpliceReports
  class Filter < ActiveRecord::Base
    include FilterSearch::Filter if Katello.config.use_elasticsearch

    has_and_belongs_to_many :organizations, :join_table => 'splice_reports_filters_organizations', :foreign_key=>'splice_reports_filter_id'
    belongs_to :user

    validates :name, :presence => true
    validates :status, :presence => true
    validates_with Validators::KatelloNameFormatValidator, :attributes => :name
    validates_with Validators::KatelloDescriptionFormatValidator, :attributes => :description

    validate :additional_criteria
    #validate :only_one_additional_criteria

    def additional_criteria
       if self.start_date.blank? && self.hours.blank? && self.inactive.blank?
        errors[:base] << "Please choose one of the options from Additional Filter Criteria"
      end
      
    end

    #this is not working as designed yet.
    #def only_one_additional_criteria
    #   if self.start_date.present? && !self.hours.present?
    #    errors[:base] << "Please choose only one of the options from Additional Filter Criteria"
    #  end
    #  
    #end

    before_destroy :prevent_locked_deletion


    private 

    def prevent_locked_deletion
      if self.locked?
        Rails.logger.error _("Red Hat provider can not be deleted")
        false
      else
        true
      end
    end

  end 
end
