# frozen_string_literal: true

FactoryBot.define do
  factory :day do
    date { Date.new(2023, 1, 1) }
    schedule { 'off' }
    association :calendar

    trait :full_time do
      date { Date.new(2023, 1, 2) }
      schedule { 'full-time' }
    end
  end
end
