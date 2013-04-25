class AddFiltersOrganizations < ActiveRecord::Migration
  def change
    create_table :splice_reports_filters_organizations, :id=>false do |t|
      t.belongs_to :splice_reports_filter, :organization
    end
    add_index :splice_reports_filters_organizations, :splice_filter_id
    add_index :splice_reports_filters_organizations, :organization_id
  end
end
