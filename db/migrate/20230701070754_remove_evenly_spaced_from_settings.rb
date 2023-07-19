# frozen_string_literal: true

class RemoveEvenlySpacedFromSettings < ActiveRecord::Migration[7.0]
  def change
    remove_column :settings, :evenly_spaced, :boolean
  end
end
