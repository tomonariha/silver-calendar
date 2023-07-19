# frozen_string_literal: true

FactoryBot.define do
  factory :setting do
    period_start_at { Date.new(2023, 1, 1) }
    period_end_at { Date.new(2023, 1, 31) }
    total_working_days { '20' }
    schedule_of_sunday { 'off' }
    schedule_of_monday { 'full-time' }
    schedule_of_tuesday { 'full-time' }
    schedule_of_wednesday { 'full-time' }
    schedule_of_thursday { 'full-time' }
    schedule_of_friday { 'full-time' }
    schedule_of_saturday { 'off' }
    association :calendar
  end
end
