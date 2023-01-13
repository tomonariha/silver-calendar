class CreateSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :settings do |t|
      t.references :calendar, foreign_key: true
      t.date :period_start_at
      t.date :period_end_at
      t.integer :total_working_days
      t.integer :minimum_working_day_of_a_week
      t.integer :minimum_days_off_of_a_week
      t.boolean :evenly_spaced
      t.string :schedule_of_sunday
      t.string :schedule_of_monday
      t.string :schedule_of_tuesday
      t.string :schedule_of_wednesday
      t.string :schedule_of_thursday
      t.string :schedule_of_friday
      t.string :schedule_of_saturday
      t.timestamps
    end
  end
end
