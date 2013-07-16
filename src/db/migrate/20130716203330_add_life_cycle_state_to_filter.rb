class AddLifeCycleStateToFilter < ActiveRecord::Migration
  def change
    add_column :splice_reports_filters, :state, :string, :null=>true
  end
end
