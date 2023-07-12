# frozen_string_literal: true

class Day < ApplicationRecord
  belongs_to :calendar
  validates :date, presence: true
  validate :schedule_should_be_valid_string

  private

  def schedule_should_be_valid_string
    return if schedule.in? %w[full-time morning afternoon off None paidleave]

    errors.add(:schedule, '無効な文字列です')
  end
end
