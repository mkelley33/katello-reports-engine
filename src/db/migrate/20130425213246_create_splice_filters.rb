class CreateSpliceFilters < ActiveRecord::Migration
  def change
    create_table :splice_reports_filters do |t|
      t.string :name, :null=>false 
      t.string :description
      t.boolean :locked, :null=>false, :default=>false
      t.integer :hours
      t.string :satellite_name, :null=>false
      t.datetime :start_date
      t.datetime :end_date
      t.string :status
      t.timestamps
    end
  end
end
