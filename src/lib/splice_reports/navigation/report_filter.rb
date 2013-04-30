module SpliceReports
  module Navigation

    class ReportFilter < ::Experimental::Navigation::Item

      def initialize()
        @key           = :splice_reports_filters
        @display       = _("Reports")
        @authorization = lambda{true}
        @url           = splice_reports_filters_path
      end

    end

  end
end
