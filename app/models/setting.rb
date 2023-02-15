# frozen_string_literal: true

class Setting < ApplicationRecord
  belongs_to :calendar, dependent: :destroy
  with_options presence: true do
    validates :calendar_id
    validates :period_start_at
    validates :period_end_at
  end
  validate :period_start_at_should_be_before_period_end_at
  validate :schedule_should_be_valid_string
  validate :total_working_days_should_be_between_0_and_days_in_period
  validate :periods_should_not_overlap

  private

  def schedule_should_be_valid_string
    unless (schedule_of_sunday == 'full-time') ||
           (schedule_of_sunday == 'morning') ||
           (schedule_of_sunday == 'afternoon') ||
           (schedule_of_sunday == 'off') ||
           (schedule_of_sunday == 'None')
      errors.add(:schedule_of_sunday, '無効な文字列です')
    end
  end

  def period_start_at_should_be_before_period_end_at
    return unless period_start_at && period_end_at

    return unless period_start_at > period_end_at

    errors.add(:period_start_at, '開始日が終了日以前になるようにしてください')
  end

  def total_working_days_should_be_between_0_and_days_in_period
    return unless total_working_days

    number_of_days_in_period = (period_start_at...period_end_at).count
    return unless (total_working_days > number_of_days_in_period) || total_working_days.negative?

    errors.add(:total_working_days, '勤務日数は０以上期間内の日数以下にしてください')
  end

  def periods_should_not_overlap
    return unless period_start_at && period_end_at
    calendar_of_this_year = Calendar.find(calendar_id)
    return unless calendar_of_this_year

    settings = calendar_of_this_year.settings
    settings.each do |setting|
      next if setting.id == id
      period = setting.period_start_at...setting.period_end_at
      errors.add(:period_start_at, '他の条件の期間と重ならないようにしてください') if period.include?(period_start_at) || period.include?(period_end_at)
    end
  end
end
