# frozen_string_literal: true

class Day < ApplicationRecord
  belongs_to :calendar
  validates :date, presence: true
  validate :schedule_should_be_valid_string

  private

  def schedule_should_be_valid_string
    unless (schedule == 'full-time') ||
           (schedule == 'morning') ||
           (schedule == 'afternoon') ||
           (schedule == 'off') ||
           (schedule == 'paidleave')
      errors.add(:schedule, '無効な文字列です')
    end
  end
end
