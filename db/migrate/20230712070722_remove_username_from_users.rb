# frozen_string_literal: true

class RemoveUsernameFromUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :username, :string
  end
end
