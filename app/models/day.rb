# frozen_string_literal: true

class Day < ApplicationRecord
  belongs_to :calendar
  with_options presence: true do
    validates :calendar_id
    validates :date
  end
  validate :schedule_should_be_valid_string

  private

  def schedule_should_be_valid_string
    unless (schedule == 'full-time') ||
           (schedule == 'morning') ||
           (schedule == 'afternoon') ||
           (schedule == 'off')
      errors.add(:schedule, '無効な文字列です')
    end
  end
end
