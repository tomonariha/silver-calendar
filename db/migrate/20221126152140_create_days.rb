# frozen_string_literal: true

class CreateDays < ActiveRecord::Migration[7.0]
  def change
    create_table :days do |t|
      t.references :calendar, foreign_key: true
      t.date :date, null: false
      t.string :schedule
      t.boolean :locked
      t.timestamps
    end
  end
end
