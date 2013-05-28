class SpliceReportsFilterChangeInactive < ActiveRecord::Migration
  def change
    remove_column :splice_reports_filters, :inactive
  end
end
