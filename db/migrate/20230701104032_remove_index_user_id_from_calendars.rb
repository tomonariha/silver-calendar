class RemoveIndexUserIdFromCalendars < ActiveRecord::Migration[7.0]
  def change
    remove_index :calendars, name: :index_calendars_on_user_id
  end
end
