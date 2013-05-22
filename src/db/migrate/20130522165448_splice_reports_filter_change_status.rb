class SpliceReportsFilterChangeStatus < ActiveRecord::Migration
  def change
    change_column :splice_reports_filters, :status, :text
  end
end
