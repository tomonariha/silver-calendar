# frozen_string_literal: true

class Setting < ApplicationRecord
  belongs_to :calendar
  with_options presence: true do
    validates :period_start_at
    validates :period_end_at
  end
  validate :period_start_at_should_be_before_period_end_at
  validate :schedule_should_be_valid_string
  validate :total_working_days_should_be_between_0_and_days_in_period

  private

  def schedule_should_be_valid_string
    return if schedule_of_sunday.in? %w(full-time morning afternoon off None)
    errors.add(:schedule_of_sunday, '無効な文字列です')
  end

  def period_start_at_should_be_before_period_end_at
    return unless period_start_at && period_end_at

    return unless period_start_at > period_end_at

    errors.add(:period_start_at, '開始日が終了日以前になるようにしてください')
  end

  def total_working_days_should_be_between_0_and_days_in_period
    return unless total_working_days

    number_of_days_in_period = (period_start_at..period_end_at).count

    return unless (total_working_days > number_of_days_in_period) || total_working_days.negative?

    errors.add(:total_working_days, '勤務日数は０以上期間内の日数以下にしてください')
  end
end
