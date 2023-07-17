# frozen_string_literal: true

class AddTimeColumnsToUsers < ActiveRecord::Migration[7.0]
  def change
    change_table :users, bulk: true do |t|
      t.integer :morning_start_hour, default: 8
      t.integer :users, :morning_start_minit, default: 0
      t.integer :users, :morning_end_hour, default: 12
      t.integer :users, :morning_end_minit, default: 0
      t.integer :users, :after_noon_start_hour, default: 13
      t.integer :users, :after_noon_start_minit, default: 0
      t.integer :users, :after_noon_end_hour, default: 17
      t.integer :users, :after_noon_end_minit, default: 0
      t.integer :users, :full_time_start_hour, default: 8
      t.integer :users, :full_time_start_minit, default: 0
      t.integer :users, :full_time_end_hour, default: 17
      t.integer :users, :full_time_end_minit, default: 0
    end
  end
end
