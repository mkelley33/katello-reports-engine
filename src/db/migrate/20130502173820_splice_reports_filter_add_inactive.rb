class SpliceReportsFilterAddInactive < ActiveRecord::Migration
  def change
    add_column :splice_reports_filters, :inactive, :integer, :null=>true
  end
end
