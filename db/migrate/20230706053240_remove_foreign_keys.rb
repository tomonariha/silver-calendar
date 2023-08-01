# frozen_string_literal: true

class RemoveForeignKeys < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :calendars, :users
    remove_foreign_key :days, :calendars
    remove_foreign_key :settings, :calendars
  end
end
