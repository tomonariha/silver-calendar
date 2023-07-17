# frozen_string_literal: true

class CreateCalendars < ActiveRecord::Migration[7.0]
  def change
    create_table :calendars do |t|
      t.references :user, foreign_key: true
      t.integer :year, null: false
      t.string :google_calendar_id
      t.timestamps
    end
  end
end
