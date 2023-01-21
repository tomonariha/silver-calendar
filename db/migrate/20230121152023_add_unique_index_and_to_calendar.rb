class AddUniqueIndexAndToCalendar < ActiveRecord::Migration[7.0]
  def change
    add_index :calendars, [:user_id, :year], unique: true
  end
end
