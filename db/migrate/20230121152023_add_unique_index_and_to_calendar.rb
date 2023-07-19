# frozen_string_literal: true

class AddUniqueIndexAndToCalendar < ActiveRecord::Migration[7.0]
  def change
    add_index :calendars, %i[user_id year], unique: true
  end
end
