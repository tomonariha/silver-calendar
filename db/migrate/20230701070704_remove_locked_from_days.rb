# frozen_string_literal: true

class RemoveLockedFromDays < ActiveRecord::Migration[7.0]
  def change
    remove_column :days, :locked, :boolean
  end
end
