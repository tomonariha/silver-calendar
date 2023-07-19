# frozen_string_literal: true

class RemoveIndexUserIdFromCalendars < ActiveRecord::Migration[7.0]
  def up
    remove_index :calendars, name: :index_calendars_on_user_id
  end

  def down
    add_index :calendars, :user_id
  end
end
