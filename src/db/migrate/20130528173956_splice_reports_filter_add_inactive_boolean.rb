class SpliceReportsFilterAddInactiveBoolean < ActiveRecord::Migration
  def change
    add_column :splice_reports_filters, :inactive, :boolean
  end
end
