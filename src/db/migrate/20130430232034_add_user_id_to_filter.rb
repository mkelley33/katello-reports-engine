class AddUserIdToFilter < ActiveRecord::Migration
  def change
    add_column :splice_reports_filters, :user_id, :integer, :null=>true
  end
end
