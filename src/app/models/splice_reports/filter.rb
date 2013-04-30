module SpliceReports
  class Filter < ActiveRecord::Base
    include FilterSearch::Filter if Katello.config.use_elasticsearch

    has_and_belongs_to_many :organizations, :join_table => 'splice_reports_filters_organizations', :foreign_key=>'splice_reports_filter_id'

    validates :name, :presence => true
    validates_with Validators::KatelloNameFormatValidator, :attributes => :name
    validates_with Validators::KatelloDescriptionFormatValidator, :attributes => :description

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
