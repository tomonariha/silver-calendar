# frozen_string_literal: true

FactoryBot.define do
  factory :setting do
    period_start_at { Date.new(2023, 1, 1) }
    period_end_at { Date.new(2023, 12, 31) }
    total_working_days { '180' }
    schedule_of_sunday { 'full-time' }
    association :calendar
  end
end
