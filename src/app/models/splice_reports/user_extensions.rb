module SpliceReports
  module UserExtensions

    extend ActiveSupport::Concern

    included do
      has_many :splice_reports_filters, :class_name=>SpliceReports::Filter, :dependent=>:destroy
    end

  end
end