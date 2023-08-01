# frozen_string_literal: true

class ChangeColumnsAddNotNullToForeignKeys < ActiveRecord::Migration[7.0]
  def change
    change_column_null(:calendars, :user_id, false)
    change_column_null(:settings, :calendar_id, false)
    change_column_null(:days, :calendar_id, false)
  end
end
