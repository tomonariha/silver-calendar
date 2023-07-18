# frozen_string_literal: true

class ChangeDefaultScheduleToDays < ActiveRecord::Migration[7.0]
  def up
    change_column :days, :schedule, :string, default: 'None'
  end

  def down
    change_column :days, :schedule, :string
  end
end
