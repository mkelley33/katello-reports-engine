module SpliceReports
  class Filter < ActiveRecord::Base
    has_many :organizations


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
