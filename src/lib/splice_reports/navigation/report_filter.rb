module SpliceReports
  module Navigation

=begin
    class ReportFilter < ::Experimental::Navigation::Item

      def initialize(organization)
        @key           = :special_filters
        @display       = _("Report Filters")
        @authorization = lambda{ organization && organization.readable? }
        @url           = report_filters_path
      end

    end
=end
  end
end
