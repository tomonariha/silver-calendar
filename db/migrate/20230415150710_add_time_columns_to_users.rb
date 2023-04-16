class AddTimeColumnsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :morning_start_hour, :integer, default: 8
    add_column :users, :morning_start_minit, :integer, default: 0
    add_column :users, :morning_end_hour, :integer, default: 12
    add_column :users, :morning_end_minit, :integer, default: 0
    add_column :users, :after_noon_start_hour, :integer, default: 13
    add_column :users, :after_noon_start_minit, :integer, default: 0
    add_column :users, :after_noon_end_hour, :integer, default: 17
    add_column :users, :after_noon_end_minit, :integer, default: 0
    add_column :users, :full_time_start_hour, :integer, default: 8
    add_column :users, :full_time_start_minit, :integer, default: 0
    add_column :users, :full_time_end_hour, :integer, default: 17
    add_column :users, :full_time_end_minit, :integer, default: 0
  end
end
