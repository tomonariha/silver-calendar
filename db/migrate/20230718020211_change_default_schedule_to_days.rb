# frozen_string_literal: true

class ChangeDefaultScheduleToDays < ActiveRecord::Migration[7.0]
  def change
    change_column :days, :schedule, :string, default: 'None'
  end
end
